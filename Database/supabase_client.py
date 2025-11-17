# ==============================================================================
# 📝 프로젝트: 대파마켓 (Da-pa Market)
# 📄 파일: supabase_client.py
# 👨‍💻 제작자: 서상원
# 🗓️ 마지막 수정일: 2025-11-17
# ------------------------------------------------------------------------------
# ✨ 대파마켓 앱의 모든 백엔드 API를 처리하는 Flask 서버
# ==============================================================================

from flask import Flask, jsonify, request
from supabase import create_client, Client

# ═══ ⚙️ 초기 설정 (Initialization & Setup) ══════════════════════════════════
# Flask 앱과 Supabase 클라이언트를 초기화
app = Flask(__name__)

# --- Supabase 클라이언트 설정 ---
supabase_url = "https://tvsofsaknsvkxdttuwls.supabase.co"
supabase_key = "sb_secret_M6ltrHcXwBK2XzxWthRTiQ_MhDdnayP"
supabase: Client = create_client(supabase_url, supabase_key)

# ═══ 🪵 미들웨어 (Middleware - Logging) ════════════════════════════════════
# 모든 API 요청 전후에 로그를 자동으로 출력하여 디버깅 확인

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
# 상품 조회, 등록, 상세 보기 등 상품과 관련된 모든 요청을 처리합니다.

@app.route('/products', methods=['GET'])
def get_products():
    """[GET /products] : 모든 상품 목록을 조회"""
    try:
        # Supabase의 'Product' 테이블에서 모든 데이터를 가져옵니다.
        # 'User' 테이블과 연결해서 판매자의 'User_Location' 정보도 함께 가져옵니다.
        res = supabase.table('Product').select('*, User!Product_Owner(User_Location)').execute()
        
        products_with_location = [] # Flutter로 보내줄, 깔끔하게 정리된 상품 목록을 담을 빈 리스트

        # 제품 정보를 다 긁어 모은 후 User_Location 부분이 외래키 참조라 json 파일이 복잡해짐
        # 그걸 Location 부분만 꺼내와서 json 파일의 형식을 편하게 바꾸는거
        for p in res.data:
            product_data = p
            if product_data.get('User'):
                product_data['User_Location'] = product_data['User']['User_Location'] 
                del product_data['User']
            products_with_location.append(product_data)
        
        print(f"✅ /products: {len(products_with_location)}개 상품 조회 성공")
        return jsonify(products_with_location)
    
    # 예외처리 
    except Exception as e:
        print(f"❌ /products 오류: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/products', methods=['POST'])
def create_product():
    """[POST /products] : 새로운 상품을 등록"""
    try:
        data = request.get_json() # Flutter에서 보낸 정보를 data 변수라는 곳에 json으로 저장하는거
        
        # Flutter 앱에서 보낸 데이터 필드들을 명시적으로 확인
        product_to_insert = {
            'Product_Name': data.get('Product_Name'), 	# 제품 이름
            'Product_Picture': data.get('Product_Picture'), # 제품 사진
            'Product_Price': data.get('Product_Price'), 	# 제품 가격
            'Product_Info': data.get('Product_Info'), 	# 제품 상세 정보
            'Product_Owner': data.get('Product_Owner'), 	# 제품 올린사람
            'Product_State': True 				# 판매상태 (새 상품은 무조건 True)
        }

        # 필수 값(상품명, 판매자)이 모두 있는지 확인하고, 하나라도 없으면 입장을 막는 가드 역할
        if not all([product_to_insert['Product_Name'], product_to_insert['Product_Owner']]):
            return jsonify({"error": "상품명과 판매자 정보는 필수입니다."}), 400
        
        # 데이터베이스에 최종적으로 정리된 상품 정보를 삽입(insert)
        res = supabase.table('Product').insert(product_to_insert).execute()
        print(f"✅ /products: 새 상품 등록 성공.")
        # 성공했다는 신호(201)와 함께, DB에 저장된 정보를 Flutter에 다시 보내줌
        return jsonify(res.data[0]), 201
    
    # 예외처리 
    except Exception as e:
        print(f"❌ /products 등록 오류: {e}")
        return jsonify({"error": str(e)}), 400

# 제품을 클릭했을 때, 그 제품의 고유 ID를 이용해서 상세 정보를 받아오는 친구
@app.route('/products/<product_id>', methods=['GET'])
def get_product_detail(product_id):
    """[GET /products/<id>] : 특정 상품의 상세 정보를 조회합니다."""
    try:
        # DB의 'Product' 테이블에서 'Product_Number'가 URL로 받은 product_id와 똑같은(.eq) 상품 하나만(.single) 찾기
        res = supabase.table('Product').select('*, User!Product_Owner(*)').eq('Product_Number', product_id).single().execute()
        
        # 만약 DB를 다 찾아봤는데도 해당 ID의 상품 데이터가 없으면
        if not res.data:
            # "상품을 찾을 수 없습니다" 라는 에러 메시지와 404 상태 코드를 Flutter에 보냄
            return jsonify({"error": "Product not found"}), 404
        # 상품을 찾았으면, 그 상품의 상세 정보를 Flutter에 보냄
        return jsonify(res.data)
    # 예외처리
    except Exception as e:
        print(f"❌ /products/{product_id} 오류: {e}")
        return jsonify({"error": str(e)}), 500

#이건 위경도 문제 해결되면 추가할 예정
@app.route('/products/nearby', methods=['GET'])
def get_nearby_products():
    """[GET /products/nearby] : 위치 기반으로 근처 상품을 조회합니다."""
    # TODO: 실제 위치 기반 검색 로직 구현 필요
    return jsonify([])


# ═══ 👤 사용자 관련 API (User Profile) ═══════════════════════════════════════
@app.route('/users/<user_id>', methods=['GET'])
def get_user_profile(user_id):
    """[GET /users/<user_id>] : 특정 사용자(User_ID)의 모든 정보를 조회합니다."""
    try:
        # 'User' 테이블에서 'User_ID' 컬럼이 URL로 받은 user_id와 똑같은(.eq) 사용자 하나만(.single) 찾기
        res = supabase.table('User').select('*').eq('User_ID', user_id).single().execute()

        # 데이터가 없으면 404 에러 반환
        if not res.data:
            print(f"⚠️ /users/{user_id}: 사용자를 찾을 수 없음")
            return jsonify({"error": "User not found"}), 404

        # 사용자 정보를 찾았으면 반환
        user_data = res.data
        print(f"✅ /users/{user_id}: 사용자 정보 조회 성공")
        
        # 보안을 위해 비밀번호 필드는 제외하고 반환하는 것이 일반적이지만,
        # 현재 DB 스키마에 따라 모든 필드를 반환합니다.
        return jsonify(user_data)
        
    except Exception as e:
        print(f"❌ /users/{user_id} 오류: {e}")
        # Supabase SingleError 등 다양한 에러가 발생할 수 있음
        return jsonify({"error": str(e)}), 500


# ═══ 💬 채팅 관련 API (Chat & Messages) ═══════════════════════════════════
# 채팅방 목록 조회, 메시지 조회 및 전송 등 채팅과 관련된 모든 요청 처리

@app.route('/chats', methods=['GET'])
def get_chat_rooms():
    """[GET /chats] : 특정 사용자가 참여 중인 채팅방 목록을 조회합니다."""
    
    # Flutter에서 보낸 URL의 ?userId=... 부분을 읽어서 user_id 변수에 저장
    user_id = request.args.get('userId')

    # 만약 userId 정보가 없으면, 400 에러를 보내고 함수를 즉시 종료
    if not user_id:
        return jsonify({"error": "userId 쿼리 파라미터가 필요합니다."}), 400
    
    try:
        # 채팅방을 가져오는데, 두 가지 조건 중 하나라도 맞으면(.or_) 가져옴
        # 1. Chat_Owner 컬럼이 user_id와 같은 경우 (내가 방장인 방)
        # 2. Chat_User 컬럼이 user_id와 같은 경우 (내가 참여자인 방)
        res = supabase.table('Chat').select('*').or_(f'Chat_Owner.eq.{user_id},Chat_User.eq.{user_id}').execute()
        print(f"✅ /chats: 사용자 {user_id}의 채팅방 {len(res.data)}개 조회 성공")
        # 조회된 채팅방 목록(res.data)을 Flutter로 보냄. 만약 목록이 비어있으면 빈 리스트([])를 보냄
        return jsonify(res.data or [])
    
    # 예외 처리
    except Exception as e:
        print(f"❌ /chats 오류: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/chats/<chat_id>/messages', methods=['GET'])
def get_messages_in_chat(chat_id):
    """[GET /chats/<id>/messages] : 특정 채팅방의 모든 메시지를 조회합니다."""
    try:
        # 'Message' 테이블에서 'Message_Chat' 컬럼이 URL로 받은 chat_id와 똑같은 모든 메시지를 찾음
        # 추가로, 메시지들을 시간(Message_Time) 순서대로 정렬해서(order) 가져옴
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
        # Flutter에서 보낸 채팅 메시지 정보를 번역해서 저장
        data = request.get_json()
        message_to_insert = {
            'Message_Chat': data.get('Message_Chat'), # 어느 채팅방에 보낼지
            'Message_User': data.get('Message_User'), # 누가 보냈는지
            'Message_Text': data.get('Message_Text') 	# 내용은 무엇인지
        }
        
        # 위 3가지 정보 중 하나라도 빠졌으면, 400 에러 보내고 함수 종료
        if not all(message_to_insert.values()):
            return jsonify({"error": "메시지 정보가 부족합니다."}), 400
            
        # DB에 메시지 정보 삽입
        res = supabase.table('Message').insert(message_to_insert).execute()
        print(f"✅ /messages: 메시지 전송 성공.")
        # 성공 신호(201)와 함께 저장된 메시지 정보를 다시 Flutter로 보내줌
        return jsonify(res.data[0]), 201
    except Exception as e:
        print(f"❌ /messages 오류: {e}")
        return jsonify({"error": str(e)}), 500


# ═══ 🚀 서버 실행 (Server Execution) ═══════════════════════════════════════
# 이 스크립트가 "python supabase_client.py" 처럼 직접 실행될 때만 아래 코드를 실행

if __name__ == '__main__':
    # debug=True: 코드 변경 시 서버 자동 재시작 등 개발 편의 기능 활성화
    app.run(debug=True, host='0.0.0.0', port=5000)