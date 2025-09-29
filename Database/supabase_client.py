# app.py
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
                del product_data['User'] # 불필요한 User 객체 제거
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
        res = supabase.table('Product').insert(data).execute()
        return jsonify(res.data[0]), 201
    except Exception as e:
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
    
    res = supabase.table('Chat').select('*').execute()
    return jsonify(res.data or [])


@app.route('/products/nearby', methods=['GET'])
def get_nearby_products():
    return jsonify([]) # 위치 기반 상품 (임시 빈 목록)

@app.route('/messages', methods=['POST'])
def post_message():
    return jsonify({"status": "message received"}), 201 # 메시지 전송 (임시 성공)
    
# ── 서버 실행 ────────────────────────────────────────────────────────────
if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=5000)
