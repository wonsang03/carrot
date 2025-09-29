# Supabase 백엔드 서버 수정 (supabase_client.py)
# supabase_client.py

from flask import Flask, jsonify, request
from supabase import create_client, Client
from flask_cors import CORS  # CORS 문제 해결을 위해 추가
import json
import traceback  # 상세한 에러 추적을 위해 추가

# ===== Supabase 연결 설정 =====
supabase_url = "https://tvsofsaknsvkxdttuwls.supabase.co"
supabase_key = "sb_secret_M6ltrHcXwBK2XzxWthRTiQ_MhDdnayP"  # 실제로는 환경변수로 관리 권장

try:
    supabase: Client = create_client(supabase_url, supabase_key)
    print("✅ Supabase 연결 성공!")
except Exception as e:
    print(f"❌ Supabase 연결 실패: {e}")
    exit(1)

# ===== Flask 앱 설정 =====
app = Flask(__name__)

# CORS 설정 (Flutter 앱에서 API 호출 허용)
CORS(app)

# JSON 응답 시 한글 깨짐 방지
app.config['JSON_AS_ASCII'] = False

# ===== 로깅 미들웨어 =====
@app.before_request
def log_request():
    """모든 요청을 로그로 기록"""
    print(f"\n>>> 📡 {request.method} {request.path}")
    if request.is_json and request.get_json():
        print(f">>> 📦 요청 데이터: {request.get_json()}")

@app.after_request
def log_response(response):
    """모든 응답을 로그로 기록"""
    print(f"<<< 📨 {response.status} {request.path} ({response.content_length or 0} bytes)")
    return response

# ========================================
# 🏠 상품 관련 API 엔드포인트
# ========================================

@app.route('/products', methods=['GET'])
def get_products():
    """
    📋 모든 상품 목록 조회 API
    - 상품 정보와 판매자 위치 정보를 JOIN하여 함께 반환
    - Flutter 앱의 홈 화면에서 호출
    """
    try:
        print("🔄 Supabase에서 상품 목록 조회 중...")

        # Supabase에서 상품과 사용자 정보를 JOIN하여 조회
        # Product 테이블과 User 테이블을 Product_Owner로 연결
        response = supabase.table('Product').select(
            '''
            *,
            User!Product_Owner(
                User_Name,
                User_Location
            )
            '''
        ).execute()

        print(f"📊 Supabase 응답: {len(response.data)}개 상품 조회됨")

        # 데이터 구조 변환 (Flutter에서 읽기 쉽게)
        products_with_location = []
        for product in response.data:
            # 기본 상품 정보 복사
            product_data = dict(product)

            # 사용자 정보가 있으면 위치 정보 추가
            if product_data.get('User') and product_data['User']:
                user_info = product_data['User']
                product_data['User_Location'] = user_info.get('User_Location', '위치 정보 없음')
                product_data['User_Name'] = user_info.get('User_Name', '알 수 없는 사용자')
                # 중복된 User 객체 제거 (Flutter에서는 필요 없음)
                del product_data['User']
            else:
                # 사용자 정보가 없는 경우 기본값 설정
                product_data['User_Location'] = '위치 정보 없음'
                product_data['User_Name'] = '알 수 없는 사용자'

            products_with_location.append(product_data)

        print(f"✅ 상품 목록 조회 성공: {len(products_with_location)}개")

        # 디버깅: 첫 번째 상품 정보 출력
        if products_with_location:
            print(f"🔍 첫 번째 상품 예시: {products_with_location[0]}")

        return jsonify(products_with_location), 200

    except Exception as e:
        print(f"❌ /products 오류 발생: {e}")
        print(f"🔍 상세 오류: {traceback.format_exc()}")
        return jsonify({
            "error": "상품 목록 조회 실패",
            "message": str(e)
        }), 500

@app.route('/products/<int:product_id>', methods=['GET'])
def get_product_detail(product_id):
    """
    🔍 특정 상품 상세 정보 조회 API
    - 상품 번호로 해당 상품의 상세 정보와 판매자 정보를 함께 반환
    - Flutter 앱의 상품 상세 화면에서 호출
    """
    try:
        print(f"🔄 상품 상세 정보 조회 중... (ID: {product_id})")

        # Supabase에서 특정 상품과 판매자 정보를 JOIN하여 조회
        response = supabase.table('Product').select(
            '''
            *,
            User!Product_Owner(
                User_Name,
                User_Location,
                User_Point
            )
            '''
        ).eq('Product_Number', product_id).single().execute()

        if not response.data:
            print(f"❌ 상품을 찾을 수 없음: {product_id}")
            return jsonify({
                "error": "상품을 찾을 수 없습니다",
                "product_id": product_id
            }), 404

        # 데이터 구조 변환
        product_data = dict(response.data)

        if product_data.get('User') and product_data['User']:
            user_info = product_data['User']
            product_data['User_Location'] = user_info.get('User_Location', '위치 정보 없음')
            product_data['User_Name'] = user_info.get('User_Name', '알 수 없는 사용자')
            product_data['User_Point'] = user_info.get('User_Point', 36)
            del product_data['User']
        else:
            product_data['User_Location'] = '위치 정보 없음'
            product_data['User_Name'] = '알 수 없는 사용자'
            product_data['User_Point'] = 36

        print(f"✅ 상품 상세 정보 조회 성공: {product_data['Product_Name']}")
        return jsonify(product_data), 200

    except Exception as e:
        print(f"❌ /products/{product_id} 오류 발생: {e}")
        print(f"🔍 상세 오류: {traceback.format_exc()}")

        # 상품이 없는 경우와 기타 오류 구분
        if "No rows found" in str(e) or "PGRST116" in str(e):
            return jsonify({
                "error": "상품을 찾을 수 없습니다",
                "product_id": product_id
            }), 404
        else:
            return jsonify({
                "error": "상품 상세 정보 조회 실패",
                "message": str(e)
            }), 500

@app.route('/products', methods=['POST'])
def create_product():
    """
    📤 새 상품 등록 API
    - Flutter 앱에서 보낸 상품 정보를 Supabase에 저장
    - 자동으로 Product_Number(Primary Key) 할당
    """
    try:
        print("🔄 새 상품 등록 요청 처리 중...")

        # 요청에서 JSON 데이터 추출
        data = request.get_json()
        if not data:
            return jsonify({"error": "요청 데이터가 없습니다"}), 400

        print(f"📦 받은 상품 데이터: {data}")

        # 필수 필드 검증
        required_fields = ['Product_Name', 'Product_Price', 'Product_Info']
        for field in required_fields:
            if field not in data or not data[field]:
                return jsonify({
                    "error": f"필수 필드가 누락되었습니다: {field}"
                }), 400

        # 기본값 설정
        product_data = {
            'Product_Name': data['Product_Name'],
            'Product_Price': int(data['Product_Price']),
            'Product_Picture': data.get('Product_Picture', ''),
            'Product_Info': data['Product_Info'],
            'Product_State': data.get('Product_State', True),  # 기본값: 판매중
            'Product_Owner': data.get('Product_Owner', 1),     # 기본값: 어드민 사용자
        }

        print(f"💾 저장할 상품 데이터: {product_data}")

        # Supabase에 상품 데이터 저장
        response = supabase.table('Product').insert(product_data).execute()

        if response.data:
            created_product = response.data[0]
            print(f"✅ 상품 등록 성공! 상품번호: {created_product['Product_Number']}")
            return jsonify(created_product), 201
        else:
            print("❌ 상품 등록 실패: 응답 데이터 없음")
            return jsonify({"error": "상품 등록 실패"}), 500

    except Exception as e:
        print(f"❌ /products POST 오류 발생: {e}")
        print(f"🔍 상세 오류: {traceback.format_exc()}")
        return jsonify({
            "error": "상품 등록 실패",
            "message": str(e)
        }), 500

# ========================================
# 💬 채팅 관련 API 엔드포인트
# ========================================

@app.route('/chats', methods=['GET'])
def get_chat_rooms():
    """
    📋 특정 사용자의 채팅방 목록 조회 API
    - 현재는 기본 구현, 추후 실제 채팅 기능 구현 시 확장
    """
    try:
        user_id = request.args.get('userId')
        if not user_id:
            return jsonify({"error": "사용자 ID가 필요합니다"}), 400

        print(f"🔄 채팅방 목록 조회 중... (사용자 ID: {user_id})")

        # 현재는 기본 구현 (실제로는 Chat 테이블에서 조회)
        # TODO: 실제 채팅 테이블 구현 후 수정 필요
        response = supabase.table('Chat').select('*').execute()

        print(f"✅ 채팅방 {len(response.data)}개 조회됨")
        return jsonify(response.data or []), 200

    except Exception as e:
        print(f"❌ /chats 오류 발생: {e}")
        return jsonify({
            "error": "채팅방 목록 조회 실패",
            "message": str(e)
        }), 500

# ========================================
# 📍 위치 관련 API 엔드포인트
# ========================================

@app.route('/products/nearby', methods=['GET'])
def get_nearby_products():
    """
    🗺️ 위치 기반 근처 상품 조회 API
    - 현재는 빈 배열 반환, 추후 GPS 기능 구현 시 확장
    """
    try:
        lat = request.args.get('lat')
        lng = request.args.get('lng')
        radius = request.args.get('radius', 5)

        print(f"🔄 근처 상품 검색... 위도:{lat}, 경도:{lng}, 반경:{radius}km")

        # TODO: 실제 위치 기반 검색 로직 구현
        # 현재는 빈 배열 반환
        return jsonify([]), 200

    except Exception as e:
        print(f"❌ /products/nearby 오류 발생: {e}")
        return jsonify([]), 200  # 오류 시에도 빈 배열 반환

# ========================================
# 💌 메시지 관련 API 엔드포인트
# ========================================

@app.route('/messages', methods=['POST'])
def post_message():
    """
    💌 새 메시지 전송 API
    - 현재는 기본 구현, 추후 실제 채팅 기능 구현 시 확장
    """
    try:
        data = request.get_json()
        print(f"📨 새 메시지 전송: {data}")

        # TODO: 실제 메시지 저장 로직 구현
        return jsonify({"status": "메시지 전송 성공"}), 201

    except Exception as e:
        print(f"❌ /messages 오류 발생: {e}")
        return jsonify({
            "error": "메시지 전송 실패",
            "message": str(e)
        }), 500

# ========================================
# 🛠️ 유틸리티 API 엔드포인트
# ========================================

@app.route('/health', methods=['GET'])
def health_check():
    """
    🔍 서버 상태 확인 API
    - 서버가 정상 작동하는지 확인하는 용도
    """
    try:
        # Supabase 연결 상태도 함께 확인
        test_response = supabase.table('Product').select('Product_Number').limit(1).execute()

        return jsonify({
            "status": "OK",
            "message": "서버가 정상 작동 중입니다",
            "supabase_connection": "OK" if test_response else "ERROR"
        }), 200

    except Exception as e:
        return jsonify({
            "status": "ERROR",
            "message": f"서버 오류: {e}"
        }), 500

@app.route('/test-data', methods=['POST'])
def create_test_data():
    """
    🧪 테스트 데이터 생성 API
    - 개발 단계에서 샘플 데이터를 쉽게 추가하기 위한 용도
    """
    try:
        print("🧪 테스트 데이터 생성 중...")

        test_products = [
            {
                'Product_Name': '아이폰 14 프로',
                'Product_Price': 800000,
                'Product_Picture': 'https://via.placeholder.com/300x300/FF6B35/FFFFFF?text=iPhone14',
                'Product_Info': '깨끗한 상태의 아이폰 14 프로입니다. 박스, 충전기 포함',
                'Product_State': True,
                'Product_Owner': 1
            },
            {
                'Product_Name': '맥북 에어 M1',
                'Product_Price': 1200000,
                'Product_Picture': 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=MacBook',
                'Product_Info': 'M1 칩 탑재 맥북에어, 거의 새것 같은 상태입니다.',
                'Product_State': True,
                'Product_Owner': 1
            },
            {
                'Product_Name': '삼성 갤럭시 북',
                'Product_Price': 600000,
                'Product_Picture': 'https://via.placeholder.com/300x300/45B7D1/FFFFFF?text=Galaxy',
                'Product_Info': '가벼운 노트북, 학업용으로 적합합니다.',
                'Product_State': True,
                'Product_Owner': 1
            }
        ]

        # 테스트 데이터를 Supabase에 저장
        response = supabase.table('Product').insert(test_products).execute()

        print(f"✅ 테스트 데이터 {len(response.data)}개 생성 완료")
        return jsonify({
            "message": f"테스트 데이터 {len(response.data)}개 생성 완료",
            "data": response.data
        }), 201

    except Exception as e:
        print(f"❌ 테스트 데이터 생성 실패: {e}")
        return jsonify({
            "error": "테스트 데이터 생성 실패",
            "message": str(e)
        }), 500

# ========================================
# 🚀 서버 실행
# ========================================

if __name__ == '__main__':
    print("\n" + "="*50)
    print("🚀 대파마켓 백엔드 서버 시작!")
    print("📡 서버 주소: http://127.0.0.1:5000")
    print("💾 데이터베이스: Supabase")
    print("="*50 + "\n")

    # Flask 개발 서버 실행
    # debug=True: 코드 변경 시 자동 재시작, 상세 에러 정보 표시
    # host='127.0.0.1': 로컬에서만 접근 가능 (보안)
    # port=5000: Flutter 앱에서 접근할 포트 번호
    app.run(
        debug=True,
        host='127.0.0.1',
        port=5000,
        use_reloader=True,  # 코드 변경 시 자동 재시작
        threaded=True       # 다중 요청 처리 가능
    )


## 주요 수정사항:
1. **CORS 설정**: Flutter 앱에서 API 호출 허용
2. **한글 지원**: JSON_AS_ASCII=False로 한글 깨짐 방지
3. **상세한 에러 처리**: traceback으로 정확한 오류 위치 파악
4. **데이터 구조 개선**: Flutter 모델과 일치하도록 응답 형식 통일
5. **헬스 체크**: 서버 상태 확인 API 추가
6. **테스트 데이터**: 개발용 샘플 데이터 생성 기능
7. **로깅 강화**: 모든 요청/응답에 대한 상세 로그