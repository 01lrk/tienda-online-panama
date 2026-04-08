-- ============================================
-- CREACIÓN DE LA BASE DE DATOS
-- ============================================
CREATE DATABASE IF NOT EXISTS tienda_online_panama;
USE tienda_online_panama;

-- ============================================
-- TABLA: Clientes
-- Almacena la información de los compradores
-- ============================================
CREATE TABLE Clientes (
    id_cliente   INT AUTO_INCREMENT PRIMARY KEY,  -- Identificador único automático
    nombre       VARCHAR(100) NOT NULL,            -- Nombre completo del cliente
    correo       VARCHAR(100) UNIQUE NOT NULL,     -- Correo único, evita duplicados
    telefono     VARCHAR(20),                      -- Número de contacto
    direccion    VARCHAR(200),                     -- Dirección de entrega
    fecha_registro DATE DEFAULT (CURRENT_DATE)     -- Fecha en que se registró
);

-- ============================================
-- TABLA: Productos
-- Catálogo de productos disponibles en la tienda
-- ============================================
CREATE TABLE Productos (
    id_producto  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(150) NOT NULL,
    categoria    VARCHAR(80),                      -- Ej: Ropa, Accesorios, Hogar
    precio       DECIMAL(10, 2) NOT NULL,          -- Precio con 2 decimales
    stock        INT DEFAULT 0,                    -- Unidades disponibles en inventario
    activo       BOOLEAN DEFAULT TRUE              -- Si el producto está disponible
);

-- ============================================
-- TABLA: Pedidos
-- Registra cada orden realizada por un cliente
-- ============================================
CREATE TABLE Pedidos (
    id_pedido    INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente   INT NOT NULL,                     -- Referencia al cliente
    fecha_pedido DATE NOT NULL,
    estado       ENUM('pendiente','enviado','entregado','cancelado') DEFAULT 'pendiente',
    total        DECIMAL(10, 2) DEFAULT 0.00,      -- Monto total del pedido
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
    -- La llave foránea garantiza que no se pueda crear un pedido sin un cliente válido
);

-- ============================================
-- TABLA: Detalle_Pedido
-- Contiene los productos específicos de cada pedido
-- ============================================
CREATE TABLE Detalle_Pedido (
    id_detalle       INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido        INT NOT NULL,
    id_producto      INT NOT NULL,
    cantidad         INT NOT NULL,
    precio_unitario  DECIMAL(10, 2) NOT NULL,      -- Precio al momento de la compra
    subtotal         DECIMAL(10, 2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    FOREIGN KEY (id_pedido)   REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

-- ============================================
-- ÍNDICES para mejorar el rendimiento
-- ============================================
CREATE INDEX idx_pedidos_fecha    ON Pedidos(fecha_pedido);
CREATE INDEX idx_pedidos_cliente  ON Pedidos(id_cliente);
CREATE INDEX idx_detalle_producto ON Detalle_Pedido(id_producto);

-- ============================================
-- INSERCIÓN DE CLIENTES
-- ============================================
INSERT INTO Clientes (nombre, correo, telefono, direccion) VALUES
('Juan Pérez',    'juan.perez@gmail.com',   '6000-1111', 'Calle 50, Ciudad de Panamá'),
('María López',   'maria.lopez@hotmail.com','6100-2222', 'Vía España, Panamá'),
('Carlos Gómez',  'carlos.g@yahoo.com',     '6200-3333', 'El Dorado, Panamá'),
('Ana Rodríguez', 'ana.rod@gmail.com',      '6300-4444', 'Chorrera, Panamá'),
('Luis Herrera',  'luis.h@gmail.com',       '6400-5555', 'Colón, Panamá');

-- ============================================
-- INSERCIÓN DE PRODUCTOS
-- ============================================
INSERT INTO Productos (nombre, categoria, precio, stock) VALUES
('Camisa casual hombre',      'Ropa',        25.99, 50),
('Vestido floral mujer',      'Ropa',        35.50, 30),
('Pantalón jean azul',        'Ropa',        45.00, 40),
('Reloj deportivo',           'Accesorios',  89.99, 20),
('Cartera de cuero',          'Accesorios',  55.00, 25),
('Lámpara de escritorio LED', 'Hogar',       32.00, 15),
('Set de toallas x3',         'Hogar',       18.75, 60),
('Audífonos Bluetooth',       'Accesorios', 120.00, 10),
('Blusa de tela lino',        'Ropa',        22.00, 35),
('Cojín decorativo',          'Hogar',       12.50, 80);

-- ============================================
-- INSERCIÓN DE PEDIDOS
-- ============================================
INSERT INTO Pedidos (id_cliente, fecha_pedido, estado, total) VALUES
(1, '2026-01-10', 'entregado', 71.99),
(2, '2026-01-15', 'entregado', 90.50),
(3, '2026-02-03', 'enviado',   45.00),
(1, '2026-02-20', 'entregado', 137.99),
(4, '2026-03-05', 'pendiente', 35.25),
(5, '2026-03-12', 'enviado',   55.00),
(2, '2026-03-18', 'entregado', 120.00),
(3, '2026-04-01', 'pendiente', 57.75);

-- ============================================
-- INSERCIÓN DE DETALLE DE PEDIDOS
-- ============================================
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 25.99),  -- Pedido 1: Camisa casual
(1, 7, 2, 18.75),  -- Pedido 1: Set de toallas x2
(2, 2, 1, 35.50),  -- Pedido 2: Vestido floral
(2, 5, 1, 55.00),  -- Pedido 2: Cartera de cuero
(3, 3, 1, 45.00),  -- Pedido 3: Pantalón jean
(4, 4, 1, 89.99),  -- Pedido 4: Reloj deportivo
(4, 1, 2, 25.99),  -- Pedido 4: 2 Camisas
(5, 9, 1, 22.00),  -- Pedido 5: Blusa de lino
(5, 10, 1, 12.50), -- Pedido 5: Cojín decorativo
(6, 5, 1, 55.00),  -- Pedido 6: Cartera
(7, 8, 1, 120.00), -- Pedido 7: Audífonos
(8, 6, 1, 32.00),  -- Pedido 8: Lámpara
(8, 9, 1, 22.00),  -- Pedido 8: Blusa
(8, 10, 1, 12.50); -- Pedido 8: Cojín

-- ============================================
-- REPORTE 1: Ventas por rango de fechas
-- Muestra todos los pedidos entre dos fechas
-- ============================================
SELECT
    p.id_pedido,
    c.nombre        AS cliente,
    p.fecha_pedido,
    p.estado,
    p.total
FROM Pedidos p
JOIN Clientes c ON p.id_cliente = c.id_cliente
WHERE p.fecha_pedido BETWEEN '2026-01-01' AND '2026-03-31'
ORDER BY p.fecha_pedido ASC;

-- ============================================
-- REPORTE 2: Productos más vendidos
-- Ordena productos por unidades totales vendidas
-- ============================================
SELECT
    pr.nombre           AS producto,
    pr.categoria,
    SUM(dp.cantidad)    AS total_vendido,
    SUM(dp.subtotal)    AS ingresos_generados
FROM Detalle_Pedido dp
JOIN Productos pr ON dp.id_producto = pr.id_producto
GROUP BY pr.id_producto, pr.nombre, pr.categoria
ORDER BY total_vendido DESC;

-- ============================================
-- REPORTE 3: Consulta de todos los clientes
-- ============================================
SELECT * FROM Clientes;

-- ============================================
-- REPORTE 4: Catálogo de productos disponibles
-- ============================================
SELECT
    nombre,
    categoria,
    precio,
    stock
FROM Productos
WHERE activo = TRUE
ORDER BY categoria, nombre;

-- ============================================
-- REPORTE 5: Detalle completo de un pedido
-- (Ejemplo: pedido número 4)
-- ============================================
SELECT
    p.id_pedido,
    c.nombre        AS cliente,
    pr.nombre       AS producto,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal
FROM Detalle_Pedido dp
JOIN Pedidos  p  ON dp.id_pedido   = p.id_pedido
JOIN Clientes c  ON p.id_cliente   = c.id_cliente
JOIN Productos pr ON dp.id_producto = pr.id_producto
WHERE p.id_pedido = 4;