# 01 SQL 실습 과제

```sql
-- 1. 상품용 데이터베이스 생성

-- 1-1. 데이터베이스 생성

CREATE DATABASE Products;

-- 1-2. 데이터베이스 접속

\c products


-- 2. 상품 테이블 설계

CREATE TABLE items
(
    item_id    SERIAL          PRIMARY KEY,                                     
    name       VARCHAR(100)    NOT NULL,                                        
    price      INT             NOT NULL,                                        
    stock      SMALLINT        NOT NULL,                                        
    category   VARCHAR(20)     NOT NULL UNIQUE REFERENCES category (category_name),    
    detail     VARCHAR(500)                                                     
);
-- 상품 ID : 고유식별자이므로 serial로 자동 배정, 기본키 설정
-- 상품명 : 최대 100자
-- 가격 : 숫자
-- 재고 : 최대 32,767개까지
-- 카테고리 : 최대 20자, 아직 번호로 잇는 방법은 모름, 그냥 category name 참조함, 카테고리 하나에만 배정(UNIQUE)
-- 상세설명 : 최대 500자 / 필수 작성하지 않아도 괜찮음, NULL 가능


-- 3. 카테고리 테이블 설계 (연결관계상 상품 테이블보다 먼저 실행)
CREATE TABLE category
(
    category_id     SERIAL      PRIMARY KEY,   
    category_name   VARCHAR(20) NOT NULL UNIQUE,      
    category_detail VARCHAR(500)              
);
-- 카테고리 ID : 고유식별자이므로 serial로 자동 배정, 기본키 설정
-- 카테고리명 : 최대 20자, 참조대상키이므로 중복 금지
-- 상세설명 : 최대 500자 / 필수 작성하지 않아도 괜찮음, NULL 가능


-- 4. 상품 장바구니 테이블 설계
CREATE TABLE cart
(
    cart_id         SERIAL      PRIMARY KEY,                                                
    user_id         INT         NOT NULL UNIQUE REFERENCES users (user_id) ON DELETE CASCADE,  
    cart_item_id    INT         NOT NULL REFERENCES items (item_id) ON DELETE CASCADE,      
    cart_qty        SMALLINT    NOT NULL                                                   
);
-- 카트 ID : 고유식별자이므로 serial로 자동 배정, 기본키 설정
-- 사용자 ID : (회원 테이블 추가) 한 사람당 하나의 카트(UNIQUE), 탈퇴하면 카트도 사라짐
-- 카트 상품 ID(외래키) : 상품 items 테이블의 상품 id를 참조, 상품이 없어지면 장바구니에서도X
 -- 수량 : 재고와 같이 최대 32,767개까지


-- 5. 회원 테이블(연습용 회원 테이블 추가, 순서상으로는 맨앞에 생성)
CREATE TABLE users
(
    user_id     SERIAL      PRIMARY KEY,
    user_name   VARCHAR(10) NOT NULL
);

-- 실제 테이블 생성은 : 회원 > 카테고리 > 상품 > 카트 순으로
-----------------------------------------------------------------------------------------------------


-- 테스트용 데이터 

-- 0. 회원 데이터
INSERT INTO users (user_name) VALUES ('이지혜');
INSERT INTO users (user_name) VALUES ('홍길동');
-- 실행 결과
-- SELECT * FROM users;
--  user_id | user_name 
-- ---------+-----------
--        1 | 이지혜
--        2 | 홍길동


-- 1. 카테고리 데이터
INSERT INTO category (category_name) VALUES ('액세서리');
INSERT INTO category (category_name) VALUES ('전자제품');

-- 실행 결과
-- SELECT * FROM category;
--  category_id | category_name | category_detail 
-- -------------+---------------+-----------------
--            1 | 액세서리      | 
--            2 | 전자제품      |


-- 2. 상품 데이터
INSERT INTO items
(
    name,
    price,
    stock,
    category,
    detail
)
VALUES
(
    '이어폰',
    30000,
    100,
    '액세서리',
    '고급 블루투스 이어폰'
);
INSERT INTO items
(
    name,
    price,
    stock,
    category,
    detail
)
VALUES
(
    '아이패드',
    2000000,
    30,
    '전자제품',
    '최신형 아이패드'
);
-- 실행 결과
-- SELECT * FROM items;
--  item_id |   name   |  price  | stock | category |        detail        
-- ---------+----------+---------+-------+----------+----------------------
--        1 | 이어폰   |   30000 |   100 | 액세서리 | 고급 블루투스 이어폰
--        2 | 아이패드 | 2000000 |    30 | 전자제품 | 최신형 아이패드

-- 외래키 에러 확인용
-- ERROR:  insert or update on table "items" violates foreign key constraint "items_category_fkey"
-- DETAIL:  Key (category)=(가전제품) is not present in table "category".
INSERT INTO items
(
    name,
    price,
    stock,
    category,
    detail
)
VALUES
(
    '전자레인지',
    1500000,
    5,
    '가전제품',
    'LG사의 전자레인지'
);


-- 3. 상품 장바구니 데이터
INSERT INTO cart (user_id, cart_item_id, cart_qty) VALUES (1, 1, 1);
INSERT INTO cart (user_id, cart_item_id, cart_qty) VALUES (2, 2, 2, 2);
-- 외래키 오류 확인용
INSERT INTO cart (user_id, cart_item_id, cart_qty) VALUES (2, 5, 1);
-- insert or update on table "cart" violates foreign key constraint "cart_cart_item_id_fkey"
-- DETAIL:  Key (cart_item_id)=(5) is not present in table "items"

-- CASCADE 확인용(아이템 삭제시 카트에서도 삭제)
DELETE FROM items WHERE item_id=1;
products=# SELECT * FROM cart;
 cart_id | user_id | cart_item_id | cart_qty 
---------+---------+--------------+----------
       4 |       2 |            2 |        2
(0 rows)

-- CASCADE 확인용(회원 삭제시 카트 삭제)
 DELETE FROM users WHERE user_id = 2;
 cart_id | user_id | cart_item_id | cart_qty 
---------+---------+--------------+----------
(0 rows)

```

<br>

---

# 02 실습 자체 피드백

## 테이블 생성
- 컬럼명을 잘못 작성했다면 기존 데이터를 유지하면서 이름을 바꿀 수 있다.
```sql
ALTER TABLE members RENAME COLUMN joint_date TO join_date;
```

## 제약 조건

- `INT`는 정수, `SMALLINT`는 -32,768부터 32,767까지의 정수를 저장한다.

- `VARCHAR(100)`은 최대 100자로 제한한다. PostgreSQL에서는 한글과 공백도 글자 수에 포함된다.  
  길이 제한이 필요 없는 긴 설명에는 `TEXT`를 사용할 수 있다.

- `PRIMARY KEY`는 행을 고유하게 구분한다. 중복과 `NULL`을 허용하지 않으므로 `NOT NULL`을 따로 적지 않아도 된다.

- `SERIAL`은 값을 생략했을 때 시퀀스에서 정수를 자동 생성하도록 설정한다. 고유성은 `PRIMARY KEY`나 `UNIQUE`가 보장한다.
  - 행을 삭제해도 시퀀스가 이전 번호로 돌아가지 않음! 즉, 2,3번 행을 지운다고 4번이 갑자기 1번이 되진 않음
  - SERIAL` 번호를 직접 입력한 경우 시퀀스가 그 값에 맞게 자동 조정되지는 않으므로 이후에도 충돌할 수 있다.


## 외래키와 참조대상키

- 외래키 : 참조'하는' 쪽의 컬럼명, 참조 대상 키 : 참조 당하는 쪽의 컬럼명

- 외래키(참조하는 컬럼)에는 보통 참조 대상과 같은 자료형을 사용한다.
  - 참조 대상이 `SERIAL`로 만든 정수 번호라면 외래 키 쪽은 보통 `INT`로 작성한다.

- 외래 키 쪽에는 별도로 `UNIQUE`를 설정하지 않았다면 같은 값이 여러 번 들어갈 수 있다.
  - 여러 상품이 같은 카테고리를 참조할 수 있다.

- 참조 대상키는 항상 고유값을 가져야 함(PRIMARY KEY 혹은 UNIQUE) # NULL은 상관없음
  - 참조 대상키가 고유값이 아니면 no unique constraint matching given keys 오류 발생

- 회원 행을 삭제하면 해당 회원을 참조하는 카트 **행 전체**가 삭제된다. 외래 키 컬럼의 값만 지워지는 것이 아니다!

## 데이터 추가

- 컬럼 목록을 생략한다면 테이블의 컬럼 순서에 맞게 값을 넣는다. 자동 생성할 자리(ex: SERIAL 등)에는 `DEFAULT`를 쓸 수 있다.
  - 단, 컬럼을 명시하는 편이 순서를 알아보기 쉽고 테이블 구조 변경에도 더 안전
```sql
INSERT INTO category VALUES (DEFAULT, '식품');
```

## 그외 주의사항
- 쉼표, 세미콜론 빼먹어서 오류나는 경우 많음