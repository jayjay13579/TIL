-- 1. 상품용 데이터베이스 생성 및 접속
DROP DATABASE IF EXISTS shop;
CREATE DATABASE shop;
\c shop -- DB 접속
-- 🚨오류케이스🚨 sql에서 데이터베이스 이름은 대문자로 써도 소문자로 저장됨.
-- 그런데 psql 명령어는 대소문자 구분함! 즉, 접속시 소문자로 DB명 입력해야함!!
-- \c Shop으로 적고 접속시 오류(database "Shop" does not exist)

-- 2. 테이블 생성
-- 회원 테이블
DROP TABLE IF EXISTS users;
CREATE TABLE users
(
    user_id     SERIAL      PRIMARY KEY,
    user_name   VARCHAR(10) NOT NULL
);

-- 카테고리 테이블
DROP TABLE IF EXISTS category;
CREATE TABLE category
(
    category_id     SERIAL      PRIMARY KEY,   
    category_name   VARCHAR(20) NOT NULL UNIQUE,  -- 카테고리 이름 서로 중복 X
    category_detail TEXT
);

-- 상품 테이블
DROP TABLE IF EXISTS items;
CREATE TABLE items
(
    item_id    SERIAL          PRIMARY KEY,                                     
    name       VARCHAR(100)    NOT NULL,                                        
    price      NUMERIC(12,2)   NOT NULL DEFAULT 0 CHECK(price >=0),                                   
    stock      SMALLINT        NOT NULL DEFAULT 0 CHECK(stock >=0),                                        
    category_id INT            NOT NULL REFERENCES category (category_id), 
    -- 🚨오류케이스🚨 items 테이블의 category_id에는 UNIQUE 있으면 안된다!!
    -- 그렇게되면 items 테이블에 카테고리당 한 상품씩밖에 등록 안됨!
    -- UNIQUE가 없어야 한 카테고리에 여러 상품을 등록할 수 있음.
    -- category 테이블의 id 중복 불가와 헷갈리지 말것!   
    detail     VARCHAR(500)                                                     
);

-- 카트 설계
DROP TABLE IF EXISTS cart_items;
CREATE TABLE cart_items
(
    cart_id         SERIAL      PRIMARY KEY,                                                
    user_id         INT         NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,  
    item_id         INT         NOT NULL REFERENCES items (item_id) ON DELETE CASCADE,      
    cart_qty        SMALLINT    NOT NULL,
    UNIQUE (user_id, item_id)   -- 각각의 중복 X 두 컬럼의 조합이 중복되지 않도록                                          
);  -- CONSTRAINT 이름을 생략하는 방식(자동으로 붙여줌, \d 테이블에서 확인)
-- 이름 적는 방식 참고: CONSTRAINT uq_cart_user_item UNIQUE (user_id, item_id)

--==========================================
-- 3. DATA DUMP 
--==========================================

-- 1. 회원 데이터
INSERT INTO users (user_name) VALUES
    ('이지혜'),
    ('홍길동'),
    ('김영수'),
    ('손흥민'),
    ('황희찬'),
    ('박지성'),
    ('성동일'),
    ('이영애'),
    ('장도연'),
    ('문상훈');

-- 2. 카테고리 데이터
INSERT INTO category (category_name) VALUES
    ('전자제품'),
    ('가전제품'),
    ('액세서리'),
    ('의류'),
    ('신발'),
    ('가방'),
    ('가구'),
    ('주방용품'),
    ('청소용품'),
    ('식품');

-- 3. 상품 데이터
INSERT INTO items (name, price, stock, category_id, detail) VALUES
('이어폰', 30000, 100, 1, '고급 블루투스 이어폰'),
('전자레인지', 1500000, 100, 2, 'LG사의 전자레인지'),
('머리끈', 1000, 100, 3, NULL),
('원피스', 30000, 50, 4, NULL),
('부츠', 50000, 36, 5, NULL),
('핸드백', 5000, 70, 6, NULL),
('소파', 130000, 18, 7, NULL),
('뒤집개', 1200000, 29, 8, NULL),
('빗자루', 1100000, 10, 9, NULL),
('사과', 1000000, 11, 10, NULL);

-- 4. 상품 장바구니 데이터
INSERT INTO cart_items (user_id, item_id, cart_qty) VALUES
(1,1,1),
(2,2,2),
(3,3,3),
(4,4,4),
(5,5,5),
(6,6,6),
(7,7,7),
(8,8,8),
(9,9,9),
(10,10,10);


-- 출력 결과

-- shop=# \dt
--              List of tables
--  Schema |    Name    | Type  |  Owner   
-- --------+------------+-------+----------
--  public | cart_items | table | postgres
--  public | category   | table | postgres
--  public | items      | table | postgres
--  public | users      | table | postgres
-- (4 rows)

-- shop=# SELECT * FROM cart_items;
--  cart_id | user_id | item_id | cart_qty 
-- ---------+---------+---------+----------
--        1 |       1 |       1 |        1
--        2 |       2 |       2 |        2
--        3 |       3 |       3 |        3
--        4 |       4 |       4 |        4
--        5 |       5 |       5 |        5
--        6 |       6 |       6 |        6
--        7 |       7 |       7 |        7
--        8 |       8 |       8 |        8
--        9 |       9 |       9 |        9
--       10 |      10 |      10 |       10
-- (10 rows)

-- shop=# SELECT * FROM category;
--  category_id | category_name | category_detail 
-- -------------+---------------+-----------------
--            1 | 전자제품      | 
--            2 | 가전제품      | 
--            3 | 액세서리      | 
--            4 | 의류          | 
--            5 | 신발          | 
--            6 | 가방          | 
--            7 | 가구          | 
--            8 | 주방용품      | 
--            9 | 청소용품      | 
--           10 | 식품          | 
-- (10 rows)

-- shop=# SELECT * FROM users;
--  user_id | user_name 
-- ---------+-----------
--        1 | 이지혜
--        2 | 홍길동
--        3 | 김영수
--        4 | 손흥민
--        5 | 황희찬
--        6 | 박지성
--        7 | 성동일
--        8 | 이영애
--        9 | 장도연
--       10 | 문상훈
-- (10 rows)

-- shop=# SELECT * FROM items;
--  item_id |    name    |   price    | stock | category_id |        detail        
-- ---------+------------+------------+-------+-------------+----------------------
--        1 | 이어폰     |   30000.00 |   100 |           1 | 고급 블루투스 이어폰
--        2 | 전자레인지 | 1500000.00 |   100 |           2 | LG사의 전자레인지
--        3 | 머리끈     |    1000.00 |   100 |           3 | 
--        4 | 원피스     |   30000.00 |    50 |           4 | 
--        5 | 부츠       |   50000.00 |    36 |           5 | 
--        6 | 핸드백     |    5000.00 |    70 |           6 | 
--        7 | 소파       |  130000.00 |    18 |           7 | 
--        8 | 뒤집개     | 1200000.00 |    29 |           8 | 
--        9 | 빗자루     | 1100000.00 |    10 |           9 | 
--       10 | 사과       | 1000000.00 |    11 |          10 | 
-- (10 rows)