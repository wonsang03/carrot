from flask import Flask, jsonify, request
from supabase import create_client, Client

supabase_url = "https://tvsofsaknsvkxdttuwls.supabase.co"
supabase_key = "sb_secret_M6ltrHcXwBK2XzxWthRTiQ_MhDdnayP"
supabase: Client = create_client(supabase_url, supabase_key)

# ── Flask 앱 ─────────────────────────────────────────────────────────────
app = Flask(__name__)

# 간단한 요청/응답 로그
@app.before_request
def _log_req():
    print(f">>> {request.method} {request.path}")

@app.after_request
def _log_resp(resp):
    # URL 경로는 'request' 객체에 들어있습니다.
    print(f"<<< {resp.status} {request.path} ({resp.content_length} bytes)")
    return resp

# [GET /products] : 모든 상품 목록 조회
@app.route('/products', methods=['GET'])
def get_products():
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

# [POST /products] : 새 상품 등록
@app.route('/products', methods=['POST'])
def create_product():
    try:
        data = request.get_json()

        product_name = data.get('Product_Name')
        product_picture = data.get('Product_Picture')
        product_price = data.get('Product_Price')
        product_owner_uuid = data.get('Product_Owner') # Flutter에서 보내주는 판매자 UUID
        
        if not all([product_name, product_picture, product_price, product_owner_uuid]):
            return jsonify({"error": "Product_Name, Product_Picture, Product_Price, Product_Owner are required"}), 400

        product_to_insert = {
            'Product_Name': product_name,
            'Product_Picture': product_picture,
            'Product_Price': product_price,
            'Product_Owner': product_owner_uuid,
            'Product_State': True # 새 상품은 기본적으로 '판매중' 상태
        }
        
        res = supabase.table('Product').insert(product_to_insert).execute()
        print(f"✅ /products: 새 상품 등록 성공. 응답: {res.data}")
        return jsonify(res.data[0]), 201
    except Exception as e:
        print(f"❌ /products 등록 오류: {e}")
        return jsonify({"error": str(e)}), 400

# [GET /products/<product_id>] : 특정 상품 상세 조회
@app.route('/products/<product_id>', methods=['GET'])
def get_product_detail(product_id):
    try:
        res = supabase.table('Product').select('*, User!Product_Owner(*)').eq('Product_Number', product_id).single().execute()
        return jsonify(res.data)
    except Exception as e:
        return jsonify({"error": "Product not found"}), 404

# [GET /chats] : 특정 사용자의 채팅방 목록 조회
@app.route('/chats', methods=['GET'])
def get_chat_rooms():
    user_id = request.args.get('userId')
    if not user_id:
        return jsonify({"error": "userId is required"}), 400
    
    try:
        res = supabase.table('Chat').select('*').or_(f'Chat_Owner.eq.{user_id},Chat_User.eq.{user_id}').execute()
        print(f"✅ /chats: 사용자 {user_id}의 채팅방 {len(res.data)}개 조회 성공")
        return jsonify(res.data or [])
    except Exception as e:
        print(f"❌ /chats 오류: {e}")
        return jsonify({"error": str(e)}), 500

# [GET /chats/<chat_id>/messages] : 특정 채팅방의 메시지 목록 조회
@app.route('/chats/<chat_id>/messages', methods=['GET'])
def get_messages_in_chat(chat_id):
    if not chat_id:
        return jsonify({"error": "chat_id is required"}), 400
        
    try:
        res = supabase.table('Message').select('*').eq('Message_Chat', chat_id).order('Message_Time', desc=False).execute()
        print(f"✅ /chats/{chat_id}/messages: 메시지 {len(res.data)}개 조회 성공")
        return jsonify(res.data or [])
    except Exception as e:
        print(f"❌ /chats/{chat_id}/messages 오류: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/products/nearby', methods=['GET'])
def get_nearby_products():
    # TODO: 실제 위치 기반 검색 로직 구현 필요
    return jsonify([])

# [POST /messages] : 메시지 전송
@app.route('/messages', methods=['POST'])
def post_message():
    data = request.get_json()
    
    chat_id = data.get('Message_Chat')
    sender_id = data.get('Message_User')
    message_text = data.get('Message_Text')
    
    if not all([chat_id, sender_id, message_text]):
        return jsonify({"error": "Message_Chat, Message_User, Message_Text are required"}), 400
        
    try:
        message_to_insert = {
            'Message_Chat': chat_id,
            'Message_User': sender_id,
            'Message_Text': message_text
        }
        
        res = supabase.table('Message').insert(message_to_insert).execute()
        print(f"✅ /messages: 메시지 전송 성공. 응답: {res.data}")
        return jsonify(res.data[0]), 201
    except Exception as e:
        print(f"❌ /messages 오류: {e}")
        return jsonify({"error": str(e)}), 500
    
# ── 서버 실행 ────────────────────────────────────────────────────────────
if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=5000)
