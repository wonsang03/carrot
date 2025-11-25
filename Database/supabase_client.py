# ==============================================================================
# 📝 프로젝트: 대파마켓 (Da-pa Market)
# 📄 파일: supabase_client.py
# 👨‍💻 최종 반영일: 2025-11-25 (이미지 URL 및 DB 호환성 최종 적용)
# ------------------------------------------------------------------------------
# ✨ 대파마켓 앱의 모든 백엔드 API를 처리하는 Flask 서버
# ==============================================================================

from flask import Flask, jsonify, request
from supabase import create_client, Client

# ═══ ⚙️ 초기 설정 (Initialization & Setup) ══════════════════════════════════
app = Flask(__name__)

# --- Supabase 클라이언트 설정 ---
supabase_url = "https://tvsofsaknsvkxdttuwls.supabase.co"
supabase_key = "sb_secret_M6ltrHcXwBK2XzxWthRTiQ_MhDdnayP"
supabase: Client = create_client(supabase_url, supabase_key)

# ═══ 🪵 미들웨어 (Middleware - Logging) ════════════════════════════════════
@app.before_request
def _log_req():
    """API 요청이 들어올 때마다 실행되는 함수"""
    print(f">>> {request.method} {request.path}")

@app.after_request
def _log_resp(resp):
    """API 응답이 나가기 직전에 실행되는 함수"""
    print(f"<<< {resp.status} {request.path} ({resp.content_length} bytes)")
    return resp


# ═══ 🏠 상품 관련 API (Products) ═══════════════════════════════════════════

@app.route('/products', methods=['GET'])
def get_products():
    """[GET /products] : 모든 상품 목록을 조회"""
    try:
        res = supabase.table('Product').select('*, User!Product_Owner(User_Location)').execute()
        
        products_with_location = []

        for p in res.data:
            product_data = p
            if product_data.get('User'):
                product_data['User_Location'] = product_data['User']['User_Location'] 
                del product_data['User']
            products_with_location.append(product_data)
        
        print(f"✅ /products: {len(products_with_location)}개 상품 조회 성공")
        return jsonify(products_with_location)
    
    except Exception as e:
        print(f"❌ /products 오류: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/products', methods=['POST'])
def create_product():
    """[POST /products] : 새로운 상품을 등록"""
    try:
        data = request.get_json()
        
        product_to_insert = {
            'Product_Name': data.get('Product_Name'),
            'Product_Picture': data.get('Product_Picture'),
            'Product_Price': data.get('Product_Price'),
            'Product_Info': data.get('Product_Info'),
            'Product_Owner': data.get('Product_Owner'),
            'Product_State': True
        }

        if not all([product_to_insert['Product_Name'], product_to_insert['Product_Owner']]):
            return jsonify({"error": "상품명과 판매자 정보는 필수입니다."}), 400
        
        res = supabase.table('Product').insert(product_to_insert).execute()
        print(f"✅ /products: 새 상품 등록 성공.")
        return jsonify(res.data[0]), 201
    
    except Exception as e:
        print(f"❌ /products 등록 오류: {e}")
        return jsonify({"error": str(e)}), 400

@app.route('/products/<product_id>', methods=['GET'])
def get_product_detail(product_id):
    """[GET /products/<id>] : 특정 상품의 상세 정보를 조회합니다."""
    try:
        res = supabase.table('Product').select('*, User!Product_Owner(*)').eq('Product_Number', product_id).execute()
        
        if not res.data:
            return jsonify({"error": "Product not found"}), 404
        
        return jsonify(res.data[0]) 
    except Exception as e:
        print(f"❌ /products/{product_id} 오류: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/products/nearby', methods=['GET'])
def get_nearby_products():
    """[GET /products/nearby] : 위치 기반으로 근처 상품을 조회합니다."""
    return jsonify([])

# ═══ 👤 사용자 관련 API (User Profile) ═══════════════════════════════════════
@app.route('/users/<user_id>', methods=['GET'])
def get_user_profile(user_id):
    """[GET /users/<user_id>] : 특정 사용자(User_ID 또는 User_Number)의 모든 정보를 조회합니다."""
    try:
        # 1. User_ID로 조회
        res = supabase.table('User').select('*').eq('User_ID', user_id).execute()

        if not res.data:
            # 2. 결과가 없으면 User_Number (UUID)로 다시 조회 시도
            res = supabase.table('User').select('*').eq('User_Number', user_id).execute()
        
        # 결과가 0행이거나 비어있으면 404 반환 (PGRST116 오류 회피)
        if not res.data:
            print(f"⚠️ /users/{user_id}: 사용자를 찾을 수 없음 (0 rows)")
            return jsonify({"error": "User not found"}), 404

        user_data = res.data[0] 
        
        # ✅ [수정] DB의 User_Image 필드를 'imageUrl' 키에 할당하고, 없으면 placehold.co 사용
        db_image_url = user_data.get('User_Image')
        
        if db_image_url and db_image_url.startswith('http'):
            user_data['imageUrl'] = db_image_url
        else:
            # ✅ [수정 완료] 접속 실패하는 via.placeholder.com 대신 placehold.co 사용
            user_data['imageUrl'] = 'https://placehold.co/150x150/EEEEEE/999999/png?text=' + user_data.get('User_ID', 'N/A')
        
        print(f"✅ /users/{user_id}: 사용자 정보 조회 성공")
        
        return jsonify(user_data)
        
    except Exception as e:
        print(f"❌ /users/{user_id} 오류: {e}")
        return jsonify({"error": str(e)}), 500

# ═══ 💬 채팅 관련 API (Chat & Messages) ═══════════════════════════════════
@app.route('/chats', methods=['GET'])
def get_chat_rooms():
    """[GET /chats] : 특정 사용자가 참여 중인 채팅방 목록을 조회합니다."""
    
    user_id = request.args.get('userId')

    if not user_id:
        return jsonify({"error": "userId 쿼리 파라미터가 필요합니다."}), 400
    
    try:
        # 1. Chat 테이블 조회
        res = supabase.table('Chat').select('*').or_(f'Chat_Owner.eq.{user_id},Chat_User.eq.{user_id}').order('Chat_Time', desc=True).execute()
        chat_rooms = res.data or []
        
        # --- 2. 상대방 이름 조회를 위한 ID 수집 및 맵핑 ---
        
        product_numbers = set()
        user_ids_to_fetch = set()
        
        for chat in chat_rooms:
            if chat.get('Chat_User') == user_id:
                product_numbers.add(chat['Chat_Owner'])

        # 3. Product IDs를 사용하여 Product Owner (Seller's UUID)를 조회
        product_owner_map = {}
        if product_numbers:
            product_res = supabase.table('Product').select('Product_Number, Product_Owner').in_('Product_Number', list(product_numbers)).execute()
            
            for product in product_res.data:
                product_owner_map[product['Product_Number']] = product['Product_Owner']
                user_ids_to_fetch.add(product['Product_Owner'])

        # 4. User IDs를 사용하여 실제 User_ID(이름)를 조회
        user_name_map = {}
        if user_ids_to_fetch:
            user_res = supabase.table('User').select('User_Number, User_ID').in_('User_Number', list(user_ids_to_fetch)).execute()
            
            for user in user_res.data:
                if user.get('User_ID'): 
                    user_name_map[user['User_Number']] = user['User_ID']
                else:
                    print(f"🛑🛑 DB 데이터 오류: UUID '{user['User_Number']}'의 User_ID 필드가 비어있습니다. 🛑🛑")

        # --- 5. 데이터 결합 및 최종 리스트 생성 ---
        final_chat_list = []
        for chat in chat_rooms:
            opponent_id = None
            opponent_name = '사용자 이름 오류' 

            current_last_message = chat.get('Chat_LastMessage')
            chat_id = chat['Chat_Number']
            
            if not current_last_message:
                last_msg_res = supabase.table('Message').select('Message_Text, Message_Time') \
                    .eq('Message_Chat', chat_id) \
                    .order('Message_Time', desc=True) \
                    .limit(1).execute()
                
                if last_msg_res.data:
                    last_message_data = last_msg_res.data[0]
                    chat['Chat_LastMessage'] = last_message_data['Message_Text']
                    chat['Chat_Time'] = last_message_data['Message_Time']
            
            if chat.get('Chat_User') == user_id:
                product_number = chat['Chat_Owner']
                seller_uuid = product_owner_map.get(product_number)
                if seller_uuid:
                    opponent_name = user_name_map.get(seller_uuid, '판매자 정보 누락')
                else:
                    opponent_name = '상품 ID 오류'
            
            chat['opponent_name'] = opponent_name 

            messages_res = supabase.table('Message').select('Message_User, Message_Read').eq('Message_Chat', chat_id).execute()
            
            unread_count = 0
            for msg in messages_res.data:
                if msg['Message_User'] != user_id and msg.get('Message_Read') is False:
                    unread_count += 1
            
            chat['Chat_UnreadCount'] = unread_count 
            final_chat_list.append(chat)
            
        print(f"✅ /chats: 사용자 {user_id}의 채팅방 {len(final_chat_list)}개 조회 및 상대방 이름 결합 성공")
        return jsonify(final_chat_list)
    
    except Exception as e:
        print(f"❌ /chats 오류: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/chats/<chat_id>/messages', methods=['GET'])
def get_messages_in_chat(chat_id):
    """[GET /chats/<id>/messages] : 특정 채팅방의 모든 메시지를 조회합니다."""
    try:
        res = supabase.table('Message').select('*').eq('Message_Chat', chat_id).order('Message_Time', desc=False).execute()
        print(f"✅ /chats/{chat_id}/messages: 메시지 {len(res.data)}개 조회 성공")
        return jsonify(res.data or [])
    except Exception as e:
        print(f"❌ /chats/{chat_id}/messages 오류: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/messages', methods=['POST'])
def post_message():
    """[POST /messages] : 새로운 메시지를 전송(저장)합니다."""
    try:
        data = request.get_json()
        message_to_insert = {
            'Message_Chat': data.get('Message_Chat'),
            'Message_User': data.get('Message_User'),
            'Message_Text': data.get('Message_Text')
        }
        if not all(message_to_insert.values()):
            return jsonify({"error": "메시지 정보가 부족합니다."}), 400
            
        res = supabase.table('Message').insert(message_to_insert).execute()
        new_message = res.data[0]
        
        # Chat 테이블의 마지막 메시지 정보 업데이트
        supabase.table('Chat').update({
            'Chat_LastMessage': new_message['Message_Text'],
            'Chat_Time': new_message['Message_Time']
        }).eq('Chat_Number', new_message['Message_Chat']).execute()
        
        print(f"✅ /messages: 메시지 전송 성공.")
        return jsonify(new_message), 201
    except Exception as e:
        print(f"❌ /messages 오류: {e}")
        return jsonify({"error": str(e)}), 500

# ═══ 📢 읽음 처리 API (Read Status) ══════════════════════════════════════
@app.route('/chats/<chat_id>/read', methods=['POST'])
def mark_chat_as_read(chat_id):
    """[POST /chats/<id>/read] : 특정 채팅방의 모든 메시지를 읽음 처리합니다."""
    
    try:
        res = supabase.table('Message').update({'Message_Read': True}).eq('Message_Chat', chat_id).execute()
        
        print(f"✅ /chats/{chat_id}/read: 채팅방 메시지 읽음 처리 성공.")
        return jsonify({"success": True, "count": len(res.data)}), 200
    
    except Exception as e:
        print(f"❌ /chats/{chat_id}/read 오류: {e}")
        return jsonify({"error": str(e)}), 500

# ═══ 🚀 서버 실행 (Server Execution) ═══════════════════════════════════════

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)