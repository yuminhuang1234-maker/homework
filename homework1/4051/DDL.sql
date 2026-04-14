-- 创建数据库
CREATE DATABASE IF NOT EXISTS taobao_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE taobao_db;

-- 1. 用户表（主表，无外键依赖）
CREATE TABLE 用户 (
    user_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID(主键)',
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    password VARCHAR(50) NOT NULL COMMENT '登录密码',
    phone VARCHAR(20) COMMENT '手机号',
    role VARCHAR(10) COMMENT '用户角色(买家/卖家)',
    register_time DATETIME COMMENT '注册时间',
    status VARCHAR(10) COMMENT '账号状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';

-- 2. 店铺表（依赖用户表）
CREATE TABLE 店铺 (
    shop_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '店铺ID(主键)',
    user_id INT NOT NULL COMMENT '卖家ID(外键)',
    shop_name VARCHAR(100) NOT NULL COMMENT '店铺名称',
    score FLOAT COMMENT '店铺评分',
    open_time DATETIME COMMENT '开店时间',
    status VARCHAR(10) COMMENT '店铺状态',
    -- 外键约束：关联用户表主键
    FOREIGN KEY (user_id) REFERENCES 用户(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺信息表';

-- 3. 商品分类表（主表，无外键依赖）
CREATE TABLE 商品分类 (
    cate_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID(主键)',
    parent_id INT COMMENT '父分类ID',
    cate_name VARCHAR(50) NOT NULL COMMENT '分类名称',
    sort INT COMMENT '分类排序'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 4. 商品表（依赖店铺表、商品分类表）
CREATE TABLE 商品 (
    pro_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '商品ID(主键)',
    shop_id INT NOT NULL COMMENT '店铺ID(外键)',
    cate_id INT NOT NULL COMMENT '分类ID(外键)',
    pro_name VARCHAR(200) NOT NULL COMMENT '商品名称',
    price DECIMAL(10,2) NOT NULL COMMENT '售价',
    stock INT NOT NULL COMMENT '库存',
    image VARCHAR(255) COMMENT '商品图片',
    put_time DATETIME COMMENT '上架时间',
    status VARCHAR(10) COMMENT '商品状态',
    -- 外键约束
    FOREIGN KEY (shop_id) REFERENCES 店铺(shop_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (cate_id) REFERENCES 商品分类(cate_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品信息表';

-- 5. 购物车表（依赖用户表、商品表）
CREATE TABLE 购物车 (
    cart_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '购物车ID(主键)',
    user_id INT NOT NULL COMMENT '用户ID(外键)',
    pro_id INT NOT NULL COMMENT '商品ID(外键)',
    quantity INT NOT NULL COMMENT '购买数量',
    add_time DATETIME COMMENT '添加时间',
    -- 外键约束
    FOREIGN KEY (user_id) REFERENCES 用户(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (pro_id) REFERENCES 商品(pro_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

-- 6. 收藏表（依赖用户表、商品表、店铺表）
CREATE TABLE 收藏 (
    col_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '收藏ID(主键)',
    user_id INT NOT NULL COMMENT '用户ID(外键)',
    pro_id INT COMMENT '商品ID(外键，可空)',
    shop_id INT COMMENT '店铺ID(外键，可空)',
    col_type VARCHAR(10) NOT NULL COMMENT '收藏类型(商品/店铺)',
    col_time DATETIME COMMENT '收藏时间',
    -- 外键约束
    FOREIGN KEY (user_id) REFERENCES 用户(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (pro_id) REFERENCES 商品(pro_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES 店铺(shop_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- 7. 订单表（依赖用户表）
CREATE TABLE 订单 (
    order_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID(主键)',
    user_id INT NOT NULL COMMENT '用户ID(外键)',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    order_status VARCHAR(20) COMMENT '订单状态',
    create_time DATETIME COMMENT '下单时间',
    address VARCHAR(255) COMMENT '收货地址',
    receiver VARCHAR(50) COMMENT '收货人',
    -- 外键约束
    FOREIGN KEY (user_id) REFERENCES 用户(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- 8. 订单商品表（依赖订单表、商品表）
CREATE TABLE 订单商品 (
    item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '订单项ID(主键)',
    order_id INT NOT NULL COMMENT '订单ID(外键)',
    pro_id INT NOT NULL COMMENT '商品ID(外键)',
    price DECIMAL(10,2) NOT NULL COMMENT '商品单价',
    quantity INT NOT NULL COMMENT '购买数量',
    subtotal DECIMAL(10,2) NOT NULL COMMENT '小计金额',
    -- 外键约束
    FOREIGN KEY (order_id) REFERENCES 订单(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (pro_id) REFERENCES 商品(pro_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单商品明细表';

-- 9. 评论表（依赖用户表、商品表、订单商品表）
CREATE TABLE 评论 (
    com_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID(主键)',
    user_id INT NOT NULL COMMENT '用户ID(外键)',
    pro_id INT NOT NULL COMMENT '商品ID(外键)',
    item_id INT NOT NULL COMMENT '订单项ID(外键)',
    content TEXT COMMENT '评论内容',
    score INT COMMENT '评分(1-5星)',
    com_time DATETIME COMMENT '评论时间',
    -- 外键约束
    FOREIGN KEY (user_id) REFERENCES 用户(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (pro_id) REFERENCES 商品(pro_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (item_id) REFERENCES 订单商品(item_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品评论表';

-- 10. 物流信息表（依赖订单表）
CREATE TABLE 物流信息 (
    log_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '物流ID(主键)',
    order_id INT NOT NULL UNIQUE COMMENT '订单ID(外键，唯一)',
    company VARCHAR(50) COMMENT '物流公司',
    tracking_no VARCHAR(50) COMMENT '物流单号',
    log_status VARCHAR(20) COMMENT '物流状态',
    update_time DATETIME COMMENT '更新时间',
    -- 外键约束
    FOREIGN KEY (order_id) REFERENCES 订单(order_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物流信息表';

-- 11. 支付信息表（依赖订单表）
CREATE TABLE 支付信息 (
    pay_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '支付ID(主键)',
    order_id INT NOT NULL UNIQUE COMMENT '订单ID(外键，唯一)',
    pay_type VARCHAR(20) COMMENT '支付方式',
    pay_amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    pay_time DATETIME COMMENT '支付时间',
    pay_status VARCHAR(10) COMMENT '支付状态',
    -- 外键约束
    FOREIGN KEY (order_id) REFERENCES 订单(order_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付信息表';

-- 1. 插入用户数据（买家+卖家）
INSERT INTO 用户 (username, password, phone, role, register_time, status)
VALUES ('张三卖家', '123456', '13800138000', '卖家', NOW(), '正常'),
       ('李四买家', '654321', '13900139000', '买家', NOW(), '正常');

-- 2. 插入店铺数据（关联卖家用户）
INSERT INTO 店铺 (user_id, shop_name, score, open_time, status)
VALUES (1, '张三数码专营店', 4.9, NOW(), '营业');

-- 3. 插入商品分类数据
INSERT INTO 商品分类 (parent_id, cate_name, sort)
VALUES (0, '手机数码', 1);

-- 4. 插入商品数据（关联店铺+分类）
INSERT INTO 商品 (shop_id, cate_id, pro_name, price, stock, image, put_time, status)
VALUES (1, 1, '华为Mate60 Pro', 5999.00, 100, 'mate60.jpg', NOW(), '上架');

-- 5. 插入购物车数据（关联买家+商品）
INSERT INTO 购物车 (user_id, pro_id, quantity, add_time)
VALUES (2, 1, 1, NOW());

-- 6. 插入订单数据（关联买家）
INSERT INTO 订单 (user_id, total_amount, order_status, create_time, address, receiver)
VALUES (2, 5999.00, '待付款', NOW(), '北京市朝阳区', '李四');

-- 7. 插入订单商品数据（关联订单+商品）
INSERT INTO 订单商品 (order_id, pro_id, price, quantity, subtotal)
VALUES (1, 1, 5999.00, 1, 5999.00);