-- dropDatabase --
drop database PrettyUsine;

-- Crear la base de datos --
CREATE DATABASE IF NOT EXISTS PrettyUsine DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
 
-- Seleccionar la base de datos --
USE PrettyUsine;
 
----------- Crear la tabla de administrador -----------
CREATE TABLE administrador (
  id_administrador int(10) UNSIGNED NOT NULL,
  nombre_administrador varchar(50) NOT NULL,
  apellido_administrador varchar(50) NOT NULL,
  correo_administrador varchar(100) NOT NULL,
  alias_administrador varchar(25) NOT NULL,
  clave_administrador varchar(100) NOT NULL,
  fecha_registro datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

 ----------- Crear la tabla de categoria -----------
 
CREATE TABLE categoria (
  id_categoria int(10) UNSIGNED NOT NULL,
  nombre_categoria varchar(50) NOT NULL,
  descripcion_categoria varchar(250) DEFAULT NULL,
  imagen_categoria varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

insert into categoria (id_categoria, nombre_categoria, descripcion_categoria) values (1,'Carnivoras', 'Las mejores plantas a nivel visual que existe en esta vida');
select * from categoria;

----------- Crear la tabla de usuarios -----------

CREATE TABLE cliente (
  id_cliente int(10) UNSIGNED NOT NULL,
  nombre_cliente varchar(50) NOT NULL,
  apellido_cliente varchar(50) NOT NULL,
  dui_cliente varchar(10) NOT NULL,
  correo_cliente varchar(100) NOT NULL,
  telefono_cliente varchar(9) NOT NULL,
  direccion_cliente varchar(250) NOT NULL,
  nacimiento_cliente date NOT NULL,
  clave_cliente varchar(100) NOT NULL,
  estado_cliente tinyint(1) NOT NULL DEFAULT 1,
  fecha_registro date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
 
----------- Crear la tabla de detalles del pedido -----------

CREATE TABLE detalle_pedido (
  id_detalle int(10) UNSIGNED NOT NULL,
  id_producto int(10) UNSIGNED NOT NULL,
  cantidad_producto smallint(6) UNSIGNED NOT NULL,
  precio_producto decimal(5,2) UNSIGNED NOT NULL,
  id_pedido int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

----------- Crear la tabla de pedidos -----------

CREATE TABLE pedido (
  id_pedido int(10) UNSIGNED NOT NULL,
  id_cliente int(10) UNSIGNED NOT NULL,
  direccion_pedido varchar(250) NOT NULL,
  estado_pedido enum('Pendiente','Finalizado','Entregado','Anulado') NOT NULL,
  fecha_registro date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

 ----------- Crear tabla producto -----------
 
CREATE TABLE producto (
  id_producto int(10) UNSIGNED NOT NULL,
  nombre_producto varchar(50) NOT NULL,
  descripcion_producto varchar(250) NOT NULL,
  precio_producto decimal(5,2) NOT NULL,
  existencias_producto int(10) UNSIGNED NOT NULL,
  imagen_producto varchar(25) NOT NULL,
  id_categoria int(10) UNSIGNED NOT NULL,
  estado_producto tinyint(1) NOT NULL,
  id_administrador int(10) UNSIGNED NOT NULL,
  fecha_registro date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

 ----------- Crear tabla tipo usuario -----------

create table tipo_usuario (
id_tipo_usuario int auto_increment primary key,
nombre_tipo_usuario varchar(50)
);

----------- Crear la tabla de valoracion -----------

CREATE TABLE valoracion (
id_valoracion int(10) UNSIGNED NOT NULL,
id_producto int(10) UNSIGNED NOT NULL,
calificacion_producto INT NULL,
comentario_producto VARCHAR(250)NULL ,
fecha_registro datetime NOT NULL DEFAULT current_timestamp(),
estado_comentario BOOLEAN NOT NULL
);
 
ALTER TABLE administrador
ADD PRIMARY KEY (id_administrador),
ADD UNIQUE KEY correo_usuario (correo_administrador),
ADD UNIQUE KEY alias_usuario (alias_administrador);
    
ALTER TABLE categoria
ADD PRIMARY KEY (id_categoria),
ADD UNIQUE KEY nombre_categoria (nombre_categoria);
  
ALTER TABLE cliente
ADD PRIMARY KEY (id_cliente),
ADD UNIQUE KEY dui_cliente (dui_cliente),
ADD UNIQUE KEY correo_cliente (correo_cliente);

ALTER TABLE detalle_pedido
ADD PRIMARY KEY (id_detalle),
ADD KEY id_producto (id_producto),
ADD KEY id_pedido (id_pedido);

ALTER TABLE pedido
ADD PRIMARY KEY (id_pedido),
ADD KEY id_cliente (id_cliente);

ALTER TABLE producto
ADD PRIMARY KEY (id_producto),
ADD UNIQUE KEY nombre_producto (nombre_producto,id_categoria),
ADD KEY id_categoria (id_categoria),
ADD KEY id_usuario (id_administrador);
 
ALTER TABLE valoracion
ADD FOREIGN KEY (id_producto)
REFERENCES producto (id_producto);

 ----------- AUTO_INCREMENT de la tabla administrador -----------
ALTER TABLE administrador
  MODIFY id_administrador int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

 ----------- AUTO_INCREMENT de la tabla categoria -----------
 
ALTER TABLE categoria
  MODIFY id_categoria int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

 ----------- AUTO_INCREMENT de la tabla cliente -----------

ALTER TABLE cliente
  MODIFY id_cliente int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

 ----------- AUTO_INCREMENT de la tabla detalle_pedido -----------

ALTER TABLE detalle_pedido
  MODIFY id_detalle int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

 ----------- AUTO_INCREMENT de la tabla pedido -----------

ALTER TABLE pedido
  MODIFY id_pedido int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

 ----------- AUTO_INCREMENT de la tabla producto -----------

ALTER TABLE producto
  MODIFY id_producto int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

 ----------- Filtros para la tabla detalle_pedido -----------

ALTER TABLE detalle_pedido
  ADD CONSTRAINT detalle_pedido_ibfk_1 FOREIGN KEY (id_producto) REFERENCES producto (id_producto) ON UPDATE CASCADE,
  ADD CONSTRAINT detalle_pedido_ibfk_2 FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido) ON UPDATE CASCADE;

 ----------- Filtros para la tabla pedido -----------

ALTER TABLE pedido
  ADD CONSTRAINT pedido_ibfk_1 FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente) ON UPDATE CASCADE;

 ----------- Filtros para la tabla producto -----------

ALTER TABLE producto
  ADD CONSTRAINT producto_ibfk_1 FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria) ON UPDATE CASCADE,
  ADD CONSTRAINT producto_ibfk_2 FOREIGN KEY (id_administrador) REFERENCES administrador (id_administrador) ON UPDATE CASCADE;
COMMIT;

-- Trigger para actualizar el stock de productos después de un nuevo pedido
DELIMITER $$
CREATE TRIGGER actualizar_stock_productos
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE producto
    SET existencias_producto = existencias_producto - NEW.cantidad_producto
    WHERE id_producto = NEW.id_producto;
END$$
DELIMITER ;

-- Función para calcular el total de un pedido
DELIMITER $$
CREATE FUNCTION calcular_total_pedido(id_pedido_param INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(dp.cantidad_producto * dp.precio_producto) INTO total
    FROM detalle_pedido dp
    WHERE dp.id_pedido = id_pedido_param;
    RETURN total;
END$$
DELIMITER ;

-- Procedimiento almacenado para obtener pedidos por estado
DELIMITER $$
CREATE PROCEDURE obtener_pedidos_por_estado(estado_pedido_param VARCHAR(20))
BEGIN
    SELECT p.id_pedido, c.nombre_cliente, c.apellido_cliente, p.direccion_pedido, p.estado_pedido, p.fecha_registro
    FROM pedido p
    JOIN cliente c ON p.id_cliente = c.id_cliente
    WHERE p.estado_pedido = estado_pedido_param;
END$$
DELIMITER ;


-- Insertar 25 categorías
INSERT INTO categoria (nombre_categoria, descripcion_categoria, imagen_categoria)
VALUES
  ('Plantas carnívoras', 'Plantas que atrapan y digieren insectos y pequeños animales.', 'carnivoras.jpg'),
  ('Suculentas', 'Plantas con tallos y hojas gruesas para almacenar agua.', 'suculentas.jpg'),
  ('Orquídeas', 'Flores exóticas y coloridas.', 'orquideas.jpg'),
  ('Cactus', 'Plantas resistentes a la sequía con espinas.', 'cactus.jpg'),
  ('Bonsáis', 'Árboles enanos cultivados en macetas.', 'bonsais.jpg'),
  ('Trepadoras', 'Plantas que se extienden sobre superficies.', 'trepadoras.jpg'),
  ('Aromáticas', 'Plantas con fragancias agradables.', 'aromaticas.jpg'),
  ('Frutales', 'Plantas que producen frutos comestibles.', 'frutales.jpg'),
  ('Palmeras', 'Árboles tropicales con hojas grandes.', 'palmeras.jpg'),
  ('Helechos', 'Plantas sin flores con frondas verde.', 'helechos.jpg'),
  ('Bulbosas', 'Plantas que crecen a partir de bulbos.', 'bulbosas.jpg'),
  ('Acuáticas', 'Plantas que viven en el agua.', 'acuaticas.jpg'),
  ('Vegetales', 'Plantas comestibles cultivadas.', 'vegetales.jpg'),
  ('Medicinales', 'Plantas con propiedades curativas.', 'medicinales.jpg'),
  ('Árboles frutales', 'Árboles que producen frutos comestibles.', 'arboles_frutales.jpg'),
  ('Arbustos', 'Plantas leñosas de porte bajo.', 'arbustos.jpg'),
  ('Flores de corte', 'Flores cultivadas para decoración.', 'flores_corte.jpg'),
  ('Trepadoras de flor', 'Plantas trepadoras que producen flores.', 'trepadoras_flor.jpg'),
  ('Bambú', 'Plantas de rápido crecimiento y múltiples usos.', 'bambu.jpg'),
  ('Plantas de interior', 'Plantas decorativas para espacios interiores.', 'plantas_interior.jpg'),
  ('Plantas de sombra', 'Plantas que toleran bien la sombra.', 'plantas_sombra.jpg'),
  ('Plantas de sol', 'Plantas que requieren mucha luz solar.', 'plantas_sol.jpg'),
  ('Hierbas culinarias', 'Plantas aromáticas utilizadas en cocina.', 'hierbas_culinarias.jpg'),
  ('Plantas crasas', 'Plantas suculentas con tallos y hojas gruesas.', 'plantas_crasas.jpg'),
  ('Plantas tropicales', 'Plantas originarias de climas cálidos y húmedos.', 'plantas_tropicales.jpg');

-- Insertar 25 clientes
INSERT INTO cliente (nombre_cliente, apellido_cliente, dui_cliente, correo_cliente, telefono_cliente, direccion_cliente, nacimiento_cliente, clave_cliente)
VALUES
  ('Ana', 'García', '12345678-9', 'ana@email.com', '1234-5678', 'Calle Principal #123', '1990-05-15', ('ana123')),
  ('Carlos', 'Martínez', '98765432-1', 'carlos@email.com', '9876-5432', 'Avenida Central #456', '1985-11-20', ('carlos123')),
  ('Laura', 'Ramírez', '45678912-3', 'laura@email.com', '4567-8912', 'Colonia Norte #789', '1992-03-08', ('laura123')),
  ('Pedro', 'Gómez', '23456789-0', 'pedro@email.com', '2345-6789', 'Boulevard Sur #101', '1988-09-22', ('pedro123')),
  ('Sofía', 'Herrera', '78901234-5', 'sofia@email.com', '7890-1234', 'Urbanización Este #567', '1995-07-10', ('sofia123')),
  ('Andrés', 'Torres', '67890123-4', 'andres@email.com', '6789-0123', 'Residencial Oeste #890', '1991-12-05', ('andres123')),
  ('Lucía', 'Díaz', '34567890-1', 'lucia@email.com', '3456-7890', 'Avenida Norte #234', '1994-04-18', ('lucia123')),
  ('Diego', 'Vargas', '90123456-7', 'diego@email.com', '9012-3456', 'Calle Central #678', '1989-10-28', ('diego123')),
  ('Camila', 'Ramos', '56789012-3', 'camila@email.com', '5678-9012', 'Colonia Este #345', '1993-06-03', ('camila123')),
  ('Javier', 'Contreras', '12345670-8', 'javier@email.com', '1234-5670', 'Boulevard Oeste #789', '1987-02-14', ('javier123')),
  ('Mariana', 'Castillo', '67890125-1', 'mariana@email.com', '6789-0125', 'Urbanización Norte #012', '1996-11-25', ('mariana123')),
  ('Óscar', 'Sánchez', '23456789-9', 'oscar@email.com', '2345-6789', 'Residencial Sur #345', '1990-08-05', ('oscar123')),
  ('Valeria', 'Guzmán', '89012345-6', 'valeria@email.com', '8901-2345', 'Avenida Este #678', '1992-01-18', ('valeria123')),
  ('Alejandro', 'Morales', '45678901-2', 'alejandro@email.com', '4567-8901', 'Calle Oeste #901', '1989-05-30', ('alejandro123')),
  ('Isabella', 'Rojas', '01234567-8', 'isabella@email.com', '0123-4567', 'Colonia Sur #234', '1995-09-12', ('isabella123')),
  ('Sebastián', 'Ortiz', '67890123-5', 'sebastian@email.com', '6789-0123', 'Boulevard Norte #567', '1991-03-27', ('sebastian123')),
  ('Daniela', 'Fuentes', '23456789-1', 'daniela@email.com', '2345-6789', 'Residencial Este #890', '1994-07-08', ('daniela123')),
  ('Mateo', 'Castañeda', '89012345-7', 'mateo@email.com', '8901-2345', 'Urbanización Oeste #123', '1990-12-20', ('mateo123')),
  ('Valentina', 'Ríos', '45678901-3', 'valentina@email.com', '4567-8901', 'Avenida Sur #456', '1993-04-02', ('valentina123')),
  ('Santiago', 'Mendoza', '01234567-9', 'santiago@email.com', '0123-4567', 'Calle Norte #789', '1992-10-15', ('santiago123')),
  ('Catalina', 'Flores', '67890125-2', 'catalina@email.com', '6789-0125', 'Colonia Este #012', '1989-06-25', ('catalina123')),
  ('Emilio', 'Vega', '23456789-2', 'emilio@email.com', '2345-6789', 'Boulevard Oeste #345', '1995-01-05', ('emilio123')),
  ('Fernanda', 'Leal', '89012345-8', 'fernanda@email.com', '8901-2345', 'Residencial Norte #678', '1991-09-18', ('fernanda123')),
  ('Nicolás', 'Cárdenas', '45678901-4', 'nicolas@email.com', '4567-8901', 'Urbanización Sur #901', '1994-11-30', ('nicolas123')),
  ('Gabriela', 'Silva', '01234567-1', 'gabriela@email.com', '0123-4567', 'Avenida Este #234', '1993-07-10', ('gabriela123'));

-- Insertar 25 productos
INSERT INTO producto (nombre_producto, descripcion_producto, precio_producto, existencias_producto, imagen_producto, id_categoria, estado_producto, id_administrador)
VALUES
  ('Venus atrapamoscas', 'Planta carnívora con hojas en forma de trampa.', 15.99, 20, 'venus.jpg', 1, 1, 1),
  ('Echeveria elegans', 'Suculenta con hojas color gris-verde.', 8.99, 30, 'echeveria.jpg', 2, 1, 1),
  ('Orquídea Phalaenopsis', 'Orquídea de flores blancas y rosadas.', 25.99, 15, 'phalaenopsis.jpg', 3, 1, 1),
  ('Cactus de barril', 'Cactus globoso con espinas gruesas.', 12.99, 25, 'cactus_barril.jpg', 4, 1, 1),
  ('Bonsái de Olmo', 'Pequeño árbol enano de la especie Olmo.', 39.99, 10, 'bonsai_olmo.jpg', 5, 1, 1),
  ('Hiedra inglesa', 'Planta trepadora de hojas verdes perennes.', 7.99, 40, 'hiedra_inglesa.jpg', 6, 1, 1),
  ('Lavanda', 'Planta aromática con flores púrpuras.', 4.99, 50, 'lavanda.jpg', 7, 1, 1),
  ('Limonero', 'Árbol frutal que produce limones.', 19.99, 15, 'limonero.jpg', 8, 1, 1),
  ('Palmera datilera', 'Palmera tropical productora de dátiles.', 29.99, 8, 'palmera_datilera.jpg', 9, 1, 1),
  ('Helecho de Boston', 'Helecho verde con frondas arqueadas.', 9.99, 35, 'helecho_boston.jpg', 10, 1, 1),
  ('Tulipán', 'Bulbo que produce flores de colores brillantes.', 3.99, 60, 'tulipan.jpg', 11, 1, 1),
  ('Jacinto de agua', 'Planta acuática con hojas redondas y flores azules.', 5.99, 45, 'jacinto_agua.jpg', 12, 1, 1),
  ('Lechuga romana', 'Variedad de lechuga cultivada para ensaladas.', 2.99, 70, 'lechuga_romana.jpg', 13, 1, 1),
  ('Aloe vera', 'Planta medicinal con gel curativo.', 6.99, 55, 'aloe_vera.jpg', 14, 1, 1),
  ('Manzano', 'Árbol frutal que produce manzanas.', 24.99, 12, 'manzano.jpg', 15, 1, 1),
  ('Buganvilia', 'Arbusto con flores de colores vivos.', 11.99, 30, 'buganvilia.jpg', 16, 1, 1),
  ('Rosa de jardín', 'Flores de corte perfumadas y elegantes.', 8.99, 40, 'rosa_jardin.jpg', 17, 1, 1),
  ('Glicina', 'Trepadora de flores colgantes y fragantes.', 14.99, 20, 'glicina.jpg', 18, 1, 1),
  ('Bambú de la suerte', 'Planta de bambú de crecimiento rápido.', 9.99, 35, 'bambu_suerte.jpg', 19, 1, 1),
  ('Dracena', 'Planta de interior con hojas largas y verdes.', 12.99, 25, 'dracena.jpg', 20, 1, 1),
  ('Begonia rex', 'Planta de sombra con hojas coloridas.', 7.99, 45, 'begonia_rex.jpg', 21, 1, 1),
  ('Geranio', 'Planta de sol con flores rojas y rosadas.', 5.99, 50, 'geranio.jpg', 22, 1, 1),
  ('Romero', 'Hierba culinaria aromática y de sabor intenso.', 3.99, 65, 'romero.jpg', 23, 1, 1),
  ('Crassula ovata', 'Suculenta en forma de árbol jade.', 10.99, 40, 'crassula_ovata.jpg', 24, 1, 1),
  ('Heliconia', 'Planta tropical con flores exóticas.', 18.99, 15, 'heliconia.jpg', 25, 1, 1);

-- Insertar 25 pedidos
INSERT INTO pedido (id_cliente, direccion_pedido, estado_pedido)
VALUES
  (1, 'Calle Principal #123, Ciudad', 'Entregado'),
  (2, 'Avenida Central #456, Ciudad', 'Pendiente'),
  (3, 'Colonia Norte #789, Ciudad', 'Finalizado'),
  (4, 'Boulevard Sur #101, Ciudad', 'Entregado'),
  (5, 'Urbanización Este #567, Ciudad', 'Pendiente'),
  (6, 'Residencial Oeste #890, Ciudad', 'Finalizado'),
  (7, 'Avenida Norte #234, Ciudad', 'Entregado'),
  (8, 'Calle Central #678, Ciudad', 'Pendiente'),
  (9, 'Colonia Este #345, Ciudad', 'Finalizado'),
  (10, 'Boulevard Oeste #789, Ciudad', 'Entregado'),
  (11, 'Urbanización Norte #012, Ciudad', 'Pendiente'),
  (12, 'Residencial Sur #345, Ciudad', 'Finalizado'),
  (13, 'Avenida Este #678, Ciudad', 'Entregado'),
  (14, 'Calle Oeste #901, Ciudad', 'Pendiente'),
  (15, 'Colonia Sur #234, Ciudad', 'Finalizado'),
  (16, 'Boulevard Norte #567, Ciudad', 'Entregado'),
  (17, 'Residencial Este #890, Ciudad', 'Pendiente'),
  (18, 'Urbanización Oeste #123, Ciudad', 'Finalizado'),
  (19, 'Avenida Sur #456, Ciudad', 'Entregado'),
  (20, 'Calle Norte #789, Ciudad', 'Pendiente'),
  (21, 'Colonia Este #012, Ciudad', 'Finalizado'),
  (22, 'Boulevard Oeste #345, Ciudad', 'Entregado'),
  (23, 'Residencial Norte #678, Ciudad', 'Pendiente'),
  (24, 'Urbanización Sur #901, Ciudad', 'Finalizado'),
  (25, 'Avenida Este #234, Ciudad', 'Entregado');
  
  
  -- Insertar 25 categorias
  INSERT INTO categoria (nombre_categoria, descripcion_categoria, imagen_categoria)
VALUES
  ('Plantas carnívoras', 'Plantas que atrapan y digieren insectos y pequeños animales.', 'carnivoras.jpg'),
  ('Suculentas', 'Plantas con tallos y hojas gruesas para almacenar agua.', 'suculentas.jpg'),
  ('Orquídeas', 'Flores exóticas y coloridas.', 'orquideas.jpg'),
  ('Cactus', 'Plantas resistentes a la sequía con espinas.', 'cactus.jpg'),
  ('Bonsáis', 'Árboles enanos cultivados en macetas.', 'bonsais.jpg'),
  ('Trepadoras', 'Plantas que se extienden sobre superficies.', 'trepadoras.jpg'),
  ('Aromáticas', 'Plantas con fragancias agradables.', 'aromaticas.jpg'),
  ('Frutales', 'Plantas que producen frutos comestibles.', 'frutales.jpg'),
  ('Palmeras', 'Árboles tropicales con hojas grandes.', 'palmeras.jpg'),
  ('Helechos', 'Plantas sin flores con frondas verde.', 'helechos.jpg'),
  ('Bulbosas', 'Plantas que crecen a partir de bulbos.', 'bulbosas.jpg'),
  ('Acuáticas', 'Plantas que viven en el agua.', 'acuaticas.jpg'),
  ('Vegetales', 'Plantas comestibles cultivadas.', 'vegetales.jpg'),
  ('Medicinales', 'Plantas con propiedades curativas.', 'medicinales.jpg'),
  ('Árboles frutales', 'Árboles que producen frutos comestibles.', 'arboles_frutales.jpg'),
  ('Arbustos', 'Plantas leñosas de porte bajo.', 'arbustos.jpg'),
  ('Flores de corte', 'Flores cultivadas para decoración.', 'flores_corte.jpg'),
  ('Trepadoras de flor', 'Plantas trepadoras que producen flores.', 'trepadoras_flor.jpg'),
  ('Bambú', 'Plantas de rápido crecimiento y múltiples usos.', 'bambu.jpg'),
  ('Plantas de interior', 'Plantas decorativas para espacios interiores.', 'plantas_interior.jpg'),
  ('Plantas de sombra', 'Plantas que toleran bien la sombra.', 'plantas_sombra.jpg'),
  ('Plantas de sol', 'Plantas que requieren mucha luz solar.', 'plantas_sol.jpg'),
  ('Hierbas culinarias', 'Plantas aromáticas utilizadas en cocina.', 'hierbas_culinarias.jpg'),
  ('Plantas crasas', 'Plantas suculentas con tallos y hojas gruesas.', 'plantas_crasas.jpg'),
  ('Plantas tropicales', 'Plantas originarias de climas cálidos y húmedos.', 'plantas_tropicales.jpg');
  
    -- Insertar 25 detalles del pedido
  INSERT INTO detalle_pedido (id_producto, cantidad_producto, precio_producto, id_pedido)
VALUES
  (1, 2, 15.99, 1),
  (2, 1, 8.99, 1),
  (3, 3, 25.99, 2),
  (4, 1, 12.99, 2),
  (5, 2, 39.99, 3),
  (6, 4, 7.99, 3),
  (7, 3, 4.99, 4),
  (8, 1, 19.99, 4),
  (9, 2, 29.99, 5),
  (10, 3, 9.99, 5),
  (11, 5, 3.99, 6),
  (12, 2, 5.99, 6),
  (13, 4, 2.99, 7),
  (14, 3, 6.99, 7),
  (15, 1, 24.99, 8),
  (16, 2, 11.99, 8),
  (17, 5, 8.99, 9),
  (18, 3, 14.99, 9),
  (19, 2, 9.99, 10),
  (20, 1, 12.99, 10),
  (21, 4, 7.99, 11),
  (22, 3, 5.99, 11),
  (23, 2, 3.99, 12),
  (24, 5, 10.99, 12),
  (25, 1, 18.99, 13);
  
      -- Insertar 25 tipo de usuario
  INSERT INTO tipo_usuario (nombre_tipo_usuario)
VALUES
  ('Administrador'),
  ('Cliente'),
  ('Empleado'),
  ('Gerente'),
  ('Supervisor'),
  ('Vendedor'),
  ('Repartidor'),
  ('Almacenista'),
  ('Proveedor'),
  ('Socio'),
  ('Invitado'),
  ('Afiliado'),
  ('Mayorista'),
  ('Minorista'),
  ('Distribuidor'),
  ('Franquicia'),
  ('Suscriptor'),
  ('Usuario básico'),
  ('Usuario premium'),
  ('Usuario vitalicio'),
  ('Usuario temporal'),
  ('Usuario restringido'),
  ('Usuario externo'),
  ('Usuario interno'),
  ('Usuario de prueba');
