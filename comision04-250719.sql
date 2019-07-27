-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 26-07-2019 a las 02:33:19
-- Versión del servidor: 10.1.35-MariaDB
-- Versión de PHP: 7.2.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `comision04`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarPar` (IN `vnombre` VARCHAR(45), `vhas_sembradas` VARCHAR(12), `vtotal_has` VARCHAR(50), `vdescripcion` VARCHAR(45), `vtipo` VARCHAR(15))  BEGIN
/*DECLARE nombre varchar(45)*/
INSERT INTO parcela (nombre,has_sembradas,total_has) VALUES (vnombre,vhas_sembradas,vtotal_has);
INSERT INTO reparto (descripcion,tipo) VALUES (vdescripcion,vtipo);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cant_por_reparto` ()  NO SQL
SELECT  DISTINCT
	re.id_reparto as id,
	re.fecha_reparto as fecha,
    (SELECT COUNT(*) FROM orden_riego WHERE id_reparto = re.id_reparto) as cantidad
FROM reparto re
inner join orden_riego orr
	on orr.id_reparto=re.id_reparto$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imprimir_ordenes` (IN `id_repar` INT)  BEGIN
SET lc_time_names = 'es_ES';
SELECT 	
		r.tipo as tipo,
        ord.id_orden_riego as recibo,
        r.fecha_reparto as fecha_reparto,
        c.nombre as canal,
        CONCAT(UPPER(u.last_name),', ',SUBSTRING_INDEX(u.first_name, ' ',1))  as usuario,
        p.nombre as parcela,
        p.num_toma as toma,
        Date_format(ord.fecha_inicio,'%Y/%M/%d') as fecha,
        Date_format(ord.fecha_inicio,'%h:%i %p')as inicio,
        ord.duracion as horas,
        CONCAT('S/. ',ord.importe) as importe
FROM orden_riego ord
INNER JOIN  reparto r
	on r.id_reparto=ord.id_reparto
INNER JOIN parcela p
	ON ord.id_parcela=p.id_parcela
INNER JOIN auth_user u
	ON p.id_auth_user=u.id
INNER JOIN canal c
	ON p.id_canal=c.id_canal
WHERE r.id_reparto = id_repar and ord.estado='Aprobada'
ORDER BY c.id_canal,p.num_toma,u.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_jugando1` (IN `id_repar` INT)  BEGIN
	DECLARE fecha date ;
	DECLARE cont int;
    DECLARE ids int;
    SET ids = (SELECT id_orden_riego from orden_riego WHERE id_orden_riego = (SELECT min(id_orden_riego) from orden_riego));
    SET cont = (SELECT COUNT(*) from orden_riego WHERE id_reparto = id_repar);
    set fecha = (SELECT fecha_inicio 
                 from orden_riego 
                 WHERE id_orden_riego=(select min(id_orden_riego) from orden_riego) and id_reparto = id_repar);
                    
    WHILE cont> 0 DO    	
      SELECT * FROM orden_riego WHERE id_orden_riego = ids;
      SET ids = ids +1;
      SET cont = cont - 1 ;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ordenes_por_reparto_por_canal` ()  NO SQL
SELECT  DISTINCT
	re.id_reparto as id_reparto,
	re.fecha_reparto as fecha,
    ca.nombre as canal,
    ca.id_canal as id_canal,
    (SELECT COUNT(*) FROM orden_riego WHERE id_reparto = re.id_reparto and pa.id_canal= ca.id_canal) as cantidad
FROM reparto re
inner join orden_riego orr
	on orr.id_reparto=re.id_reparto
inner join parcela pa
	on pa.id_parcela = orr.id_parcela
inner join canal ca 
	on ca.id_canal = pa.id_canal
order by re.id_reparto,ca.id_canal$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_prueba` ()  BEGIN
 DECLARE v1 INT DEFAULT 5;
 DECLARE tam int;
 SET @tam = (SELECT COUNT(*) FROM datos_personales);

  WHILE v1 > 0 DO
    SELECT v1 as V11;
    set v1 = v1 -1;
  END WHILE;
  
  SELECT @tam as TAMM;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registro_rapido` (IN `vnombres` VARCHAR(30), `vapellidos` VARCHAR(150), `valias` VARCHAR(20), `vcelular` CHAR(13), `vdni` CHAR(8), `vfecha_nacimiento` DATE, `vfoto` VARCHAR(150), `vsexo` CHAR(1), `vtelefono` VARCHAR(20))  BEGIN
	DECLARE Id int;
    DECLARE vusername varchar(150);
    DECLARE vcontrasena varchar(128);
    
    set vusername = vdni;
    set vcontrasena = vdni;
    
    INSERT INTO auth_user(first_name,last_name,username,password) 
    	VALUES (vnombres,vapellidos,vusername,vcontrasena);
    
    set Id = (SELECT id FROM auth_user ORDER BY id DESC LIMIT 1);
    set vusername = vdni;

    INSERT INTO datos_personales(alias,celular,dni,fecha_nacimiento,foto,id_auth_user,sexo,telefono) 
        VALUES(valias,vcelular,vdni,vfecha_nacimiento,vfoto,Id,vsexo,vtelefono);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rep_reparto` ()  NO SQL
SELECT 
	re.tipo as reparto,
	ord.id_orden_riego as id_orden,
    pa.num_toma as toma,
    ord.fecha_establecida as fecha,
    ord.duracion as hectareas,
    ca.nombre as canal,
    au.first_name as usuario   
FROM orden_riego ord

INNER JOIN parcela pa
 ON ord.id_parcela = pa.id_parcela
 
INNER JOIN canal ca
	ON ca.id_canal = pa.id_canal
    
INNER JOIN auth_user au 
	ON pa.id_auth_user=au.id
    
INNER JOIN reparto re
	ON ord.id_reparto=re.id_reparto
    
ORDER BY re.tipo ,ca.id_canal,pa.num_toma$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `agenda_asamblea`
--

CREATE TABLE `agenda_asamblea` (
  `id_agenda` int(11) NOT NULL,
  `id_asamblea` int(11) DEFAULT NULL,
  `punto_numero` int(11) DEFAULT NULL,
  `descripcion` varchar(400) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivos_parcela`
--

CREATE TABLE `archivos_parcela` (
  `id_archivos_parcela` int(11) NOT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `archivo` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asamblea`
--

CREATE TABLE `asamblea` (
  `id_asamblea` int(11) NOT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(300) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` datetime DEFAULT NULL,
  `fecha_asamblea` datetime DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `asamblea`
--

INSERT INTO `asamblea` (`id_asamblea`, `tipo`, `descripcion`, `fecha_registro`, `fecha_asamblea`, `estado`) VALUES
(1, 'General', 'Reunión editada.', '2019-06-01 00:00:00', '2019-06-02 11:31:00', '1'),
(2, 'Simple', 'Prueba desde el celular.', '2019-06-02 02:43:13', '2019-06-02 11:05:00', '3'),
(3, 'General', 'Última prueba del 2 de junio.', '2019-06-02 08:33:58', '2019-06-05 02:30:00', '2'),
(14, 'Simple', '11111', '2019-07-14 21:57:06', '2019-07-10 12:12:00', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(80) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE hp8_bin NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 2, 'add_permission'),
(6, 'Can change permission', 2, 'change_permission'),
(7, 'Can delete permission', 2, 'delete_permission'),
(8, 'Can view permission', 2, 'view_permission'),
(9, 'Can add group', 3, 'add_group'),
(10, 'Can change group', 3, 'change_group'),
(11, 'Can delete group', 3, 'delete_group'),
(12, 'Can view group', 3, 'view_group'),
(13, 'Can add user', 4, 'add_user'),
(14, 'Can change user', 4, 'change_user'),
(15, 'Can delete user', 4, 'delete_user'),
(16, 'Can view user', 4, 'view_user'),
(17, 'Can add content type', 5, 'add_contenttype'),
(18, 'Can change content type', 5, 'change_contenttype'),
(19, 'Can delete content type', 5, 'delete_contenttype'),
(20, 'Can view content type', 5, 'view_contenttype'),
(21, 'Can add session', 6, 'add_session'),
(22, 'Can change session', 6, 'change_session'),
(23, 'Can delete session', 6, 'delete_session'),
(24, 'Can view session', 6, 'view_session'),
(25, 'Can add acceso', 7, 'add_acceso'),
(26, 'Can change acceso', 7, 'change_acceso'),
(27, 'Can delete acceso', 7, 'delete_acceso'),
(28, 'Can view acceso', 7, 'view_acceso'),
(29, 'Can add asamblea', 8, 'add_asamblea'),
(30, 'Can change asamblea', 8, 'change_asamblea'),
(31, 'Can delete asamblea', 8, 'delete_asamblea'),
(32, 'Can view asamblea', 8, 'view_asamblea'),
(33, 'Can add asistencia', 9, 'add_asistencia'),
(34, 'Can change asistencia', 9, 'change_asistencia'),
(35, 'Can delete asistencia', 9, 'delete_asistencia'),
(36, 'Can view asistencia', 9, 'view_asistencia'),
(37, 'Can add canal', 10, 'add_canal'),
(38, 'Can change canal', 10, 'change_canal'),
(39, 'Can delete canal', 10, 'delete_canal'),
(40, 'Can view canal', 10, 'view_canal'),
(41, 'Can add caudal', 11, 'add_caudal'),
(42, 'Can change caudal', 11, 'change_caudal'),
(43, 'Can delete caudal', 11, 'delete_caudal'),
(44, 'Can view caudal', 11, 'view_caudal'),
(45, 'Can add comite', 12, 'add_comite'),
(46, 'Can change comite', 12, 'change_comite'),
(47, 'Can delete comite', 12, 'delete_comite'),
(48, 'Can view comite', 12, 'view_comite'),
(49, 'Can add comprobante', 13, 'add_comprobante'),
(50, 'Can change comprobante', 13, 'change_comprobante'),
(51, 'Can delete comprobante', 13, 'delete_comprobante'),
(52, 'Can view comprobante', 13, 'view_comprobante'),
(53, 'Can add destajo', 14, 'add_destajo'),
(54, 'Can change destajo', 14, 'change_destajo'),
(55, 'Can delete destajo', 14, 'delete_destajo'),
(56, 'Can view destajo', 14, 'view_destajo'),
(57, 'Can add det limpieza', 15, 'add_detlimpieza'),
(58, 'Can change det limpieza', 15, 'change_detlimpieza'),
(59, 'Can delete det limpieza', 15, 'delete_detlimpieza'),
(60, 'Can view det limpieza', 15, 'view_detlimpieza'),
(61, 'Can add det lista', 16, 'add_detlista'),
(62, 'Can change det lista', 16, 'change_detlista'),
(63, 'Can delete det lista', 16, 'delete_detlista'),
(64, 'Can view det lista', 16, 'view_detlista'),
(65, 'Can add direccion', 17, 'add_direccion'),
(66, 'Can change direccion', 17, 'change_direccion'),
(67, 'Can delete direccion', 17, 'delete_direccion'),
(68, 'Can view direccion', 17, 'view_direccion'),
(69, 'Can add limpieza', 18, 'add_limpieza'),
(70, 'Can change limpieza', 18, 'change_limpieza'),
(71, 'Can delete limpieza', 18, 'delete_limpieza'),
(72, 'Can view limpieza', 18, 'view_limpieza'),
(73, 'Can add lista', 19, 'add_lista'),
(74, 'Can change lista', 19, 'change_lista'),
(75, 'Can delete lista', 19, 'delete_lista'),
(76, 'Can view lista', 19, 'view_lista'),
(77, 'Can add multa', 20, 'add_multa'),
(78, 'Can change multa', 20, 'change_multa'),
(79, 'Can delete multa', 20, 'delete_multa'),
(80, 'Can view multa', 20, 'view_multa'),
(81, 'Can add noticia', 21, 'add_noticia'),
(82, 'Can change noticia', 21, 'change_noticia'),
(83, 'Can delete noticia', 21, 'delete_noticia'),
(84, 'Can view noticia', 21, 'view_noticia'),
(85, 'Can add obra', 22, 'add_obra'),
(86, 'Can change obra', 22, 'change_obra'),
(87, 'Can delete obra', 22, 'delete_obra'),
(88, 'Can view obra', 22, 'view_obra'),
(89, 'Can add orden riego', 23, 'add_ordenriego'),
(90, 'Can change orden riego', 23, 'change_ordenriego'),
(91, 'Can delete orden riego', 23, 'delete_ordenriego'),
(92, 'Can view orden riego', 23, 'view_ordenriego'),
(93, 'Can add parcela', 24, 'add_parcela'),
(94, 'Can change parcela', 24, 'change_parcela'),
(95, 'Can delete parcela', 24, 'delete_parcela'),
(96, 'Can view parcela', 24, 'view_parcela'),
(97, 'Can add persona', 25, 'add_persona'),
(98, 'Can change persona', 25, 'change_persona'),
(99, 'Can delete persona', 25, 'delete_persona'),
(100, 'Can view persona', 25, 'view_persona'),
(101, 'Can add reparto', 26, 'add_reparto'),
(102, 'Can change reparto', 26, 'change_reparto'),
(103, 'Can delete reparto', 26, 'delete_reparto'),
(104, 'Can view reparto', 26, 'view_reparto'),
(105, 'Can add talonario', 27, 'add_talonario'),
(106, 'Can change talonario', 27, 'change_talonario'),
(107, 'Can delete talonario', 27, 'delete_talonario'),
(108, 'Can view talonario', 27, 'view_talonario'),
(109, 'Can add usuario', 28, 'add_usuario'),
(110, 'Can change usuario', 28, 'change_usuario'),
(111, 'Can delete usuario', 28, 'delete_usuario'),
(112, 'Can view usuario', 28, 'view_usuario'),
(113, 'Can add agenda asamblea', 29, 'add_agendaasamblea'),
(114, 'Can change agenda asamblea', 29, 'change_agendaasamblea'),
(115, 'Can delete agenda asamblea', 29, 'delete_agendaasamblea'),
(116, 'Can view agenda asamblea', 29, 'view_agendaasamblea'),
(117, 'Can add archivos parcela', 30, 'add_archivosparcela'),
(118, 'Can change archivos parcela', 30, 'change_archivosparcela'),
(119, 'Can delete archivos parcela', 30, 'delete_archivosparcela'),
(120, 'Can view archivos parcela', 30, 'view_archivosparcela'),
(121, 'Can add auth group', 31, 'add_authgroup'),
(122, 'Can change auth group', 31, 'change_authgroup'),
(123, 'Can delete auth group', 31, 'delete_authgroup'),
(124, 'Can view auth group', 31, 'view_authgroup'),
(125, 'Can add auth group permissions', 32, 'add_authgrouppermissions'),
(126, 'Can change auth group permissions', 32, 'change_authgrouppermissions'),
(127, 'Can delete auth group permissions', 32, 'delete_authgrouppermissions'),
(128, 'Can view auth group permissions', 32, 'view_authgrouppermissions'),
(129, 'Can add auth permission', 33, 'add_authpermission'),
(130, 'Can change auth permission', 33, 'change_authpermission'),
(131, 'Can delete auth permission', 33, 'delete_authpermission'),
(132, 'Can view auth permission', 33, 'view_authpermission'),
(133, 'Can add auth user', 34, 'add_authuser'),
(134, 'Can change auth user', 34, 'change_authuser'),
(135, 'Can delete auth user', 34, 'delete_authuser'),
(136, 'Can view auth user', 34, 'view_authuser'),
(137, 'Presidente', 34, 'es_presidente'),
(138, 'Canalero', 34, 'es_canalero'),
(139, 'Tesorero', 34, 'es_tesorero'),
(140, 'Vocal', 34, 'es_vocal'),
(141, 'Usuario', 34, 'es_usuario'),
(142, 'Can add auth user groups', 35, 'add_authusergroups'),
(143, 'Can change auth user groups', 35, 'change_authusergroups'),
(144, 'Can delete auth user groups', 35, 'delete_authusergroups'),
(145, 'Can view auth user groups', 35, 'view_authusergroups'),
(146, 'Can add auth user user permissions', 36, 'add_authuseruserpermissions'),
(147, 'Can change auth user user permissions', 36, 'change_authuseruserpermissions'),
(148, 'Can delete auth user user permissions', 36, 'delete_authuseruserpermissions'),
(149, 'Can view auth user user permissions', 36, 'view_authuseruserpermissions'),
(150, 'Can add datos personales', 37, 'add_datospersonales'),
(151, 'Can change datos personales', 37, 'change_datospersonales'),
(152, 'Can delete datos personales', 37, 'delete_datospersonales'),
(153, 'Can view datos personales', 37, 'view_datospersonales'),
(154, 'Can add django admin log', 38, 'add_djangoadminlog'),
(155, 'Can change django admin log', 38, 'change_djangoadminlog'),
(156, 'Can delete django admin log', 38, 'delete_djangoadminlog'),
(157, 'Can view django admin log', 38, 'view_djangoadminlog'),
(158, 'Can add django content type', 39, 'add_djangocontenttype'),
(159, 'Can change django content type', 39, 'change_djangocontenttype'),
(160, 'Can delete django content type', 39, 'delete_djangocontenttype'),
(161, 'Can view django content type', 39, 'view_djangocontenttype'),
(162, 'Can add django migrations', 40, 'add_djangomigrations'),
(163, 'Can change django migrations', 40, 'change_djangomigrations'),
(164, 'Can delete django migrations', 40, 'delete_djangomigrations'),
(165, 'Can view django migrations', 40, 'view_djangomigrations'),
(166, 'Can add django session', 41, 'add_djangosession'),
(167, 'Can change django session', 41, 'change_djangosession'),
(168, 'Can delete django session', 41, 'delete_djangosession'),
(169, 'Can view django session', 41, 'view_djangosession'),
(170, 'Can add hoja asistencia', 42, 'add_hojaasistencia'),
(171, 'Can change hoja asistencia', 42, 'change_hojaasistencia'),
(172, 'Can delete hoja asistencia', 42, 'delete_hojaasistencia'),
(173, 'Can view hoja asistencia', 42, 'view_hojaasistencia'),
(174, 'Can add comp multa', 43, 'add_compmulta'),
(175, 'Can change comp multa', 43, 'change_compmulta'),
(176, 'Can delete comp multa', 43, 'delete_compmulta'),
(177, 'Can view comp multa', 43, 'view_compmulta'),
(178, 'Can add comp orden', 44, 'add_comporden'),
(179, 'Can change comp orden', 44, 'change_comporden'),
(180, 'Can delete comp orden', 44, 'delete_comporden'),
(181, 'Can view comp orden', 44, 'view_comporden'),
(182, 'Can add multa asistencia', 45, 'add_multaasistencia'),
(183, 'Can change multa asistencia', 45, 'change_multaasistencia'),
(184, 'Can delete multa asistencia', 45, 'delete_multaasistencia'),
(185, 'Can view multa asistencia', 45, 'view_multaasistencia'),
(186, 'Can add multa limpia', 46, 'add_multalimpia'),
(187, 'Can change multa limpia', 46, 'change_multalimpia'),
(188, 'Can delete multa limpia', 46, 'delete_multalimpia'),
(189, 'Can view multa limpia', 46, 'view_multalimpia'),
(190, 'Can add multa orden', 47, 'add_multaorden'),
(191, 'Can change multa orden', 47, 'change_multaorden'),
(192, 'Can delete multa orden', 47, 'delete_multaorden'),
(193, 'Can view multa orden', 47, 'view_multaorden');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user`
--

CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL,
  `password` varchar(128) COLLATE hp8_bin NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE hp8_bin NOT NULL,
  `first_name` varchar(30) COLLATE hp8_bin NOT NULL,
  `last_name` varchar(150) COLLATE hp8_bin NOT NULL,
  `email` varchar(254) COLLATE hp8_bin NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `dni` int(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_user`
--

INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `first_name`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `dni`) VALUES
(1, 'pbkdf2_sha256$120000$HG91ACukV1Kh$hL0EJUf/ywkZlO0je9nWTMrRjlGT0aa32V+5b+lRUQE=', '2019-07-18 12:06:42.572395', 1, 'grcl', 'Geral R', '[Desarrollador]', 'lareg.yors@gmail.com', 1, 1, '2018-10-24 13:32:59.769234', 76583884),
(2, 'pbkdf2_sha256$120000$AItsavlw7ynS$Q/einI9/ZHI3pyb7ECEpoT417Ap/ZdzYrblnsXz1Tms=', '2019-02-06 02:26:10.547525', 0, 'Presidente', 'Domingo Pelayo', 'Sanchez Vilchez', 'dpelayo@gmail.com', 0, 1, '2018-10-24 13:55:47.000000', 0),
(3, 'pbkdf2_sha256$120000$rbNTcxSzMZ0i$XL8cQ3Vf5ZekzzhEj2FCD901jB03tRmMKZ4MNoLfWV8=', '2018-11-13 18:03:26.536817', 0, 'Canalero', 'Saul', 'Cieza', 'scieza@hotmail.com', 0, 1, '2018-10-24 13:57:47.000000', 0),
(5, 'pbkdf2_sha256$120000$iq4pABZBLoQ1$z4W+Bhp0w90w9KUyqgHr3Ox/0xtRDp2GP3iMg7bekc8=', '2019-02-13 21:29:24.969332', 0, 'Vocal', 'Roger', 'Gonzales Chuan', 'rgonzales@gmail.com', 0, 1, '2018-10-24 21:54:31.409353', 0),
(14, 'pbkdf2_sha256$120000$xbOVaxg99CXg$ABNeamYDI8vdwzvPHFP6wOD69gWYhlfkPD6T4/XsyXc=', '2019-02-13 22:20:04.944054', 0, 'pramon', 'Josué Ramón', 'Pereda Rojas', '', 0, 1, '2018-11-09 00:31:53.927712', 27920554),
(22, 'pbkdf2_sha256$120000$deVQsxfL8L7g$6ELRKWn8NLDrYaqxmBAhAjh50uc+3RIJdbVw5+YDAZU=', NULL, 0, 'ahenry', 'Julio Henry', 'Arbildo Chavarry', 'julio.chavarry@gmail.com', 0, 1, '2018-11-09 14:24:02.074009', 44500169),
(23, 'pbkdf2_sha256$120000$s54ZBxP4w0jy$NKc9AkQ5CTpeALW0ngFuAMGT0/hRGq5o6yiXJGosO1o=', NULL, 0, 'tporfirio', 'Samuel Porfirio', 'Tirado Sánchez', 'notiene@notiene.com', 0, 1, '2018-11-09 14:40:09.442479', 0),
(24, 'pbkdf2_sha256$120000$KYDfCa6sHt71$rj1zuiYIKm375JgCV8FLexiUmcuwc2TJEZQhAj0rS6g=', NULL, 0, 'Nicolas', 'Nicolas Edwin', 'Santos Arce', 'notiene@notiene.com', 0, 1, '2018-11-09 14:43:49.634648', 0),
(25, 'pbkdf2_sha256$120000$CqNsnjNyjQUu$KpWjO4VKgWus+KmJRZ76fKQ7RNfIVLJoyQ3eUAqMzWA=', NULL, 0, 'abeatriz', 'Lina Beatriz', 'Arce Castañeda', 'notiene@notiene.com', 0, 1, '2018-11-09 14:48:07.767826', 0),
(26, 'pbkdf2_sha256$120000$RBq8Ko2B4unj$zKOJvtT9V7cdwxfTVNhu5M5SAwbhEADejIk48x87OtA=', NULL, 0, 'rpablo', 'José Pablo', 'Rojas Carrera', 'notiene@notiene.com', 0, 1, '2018-11-09 14:57:32.455057', 0),
(27, 'pbkdf2_sha256$120000$2jmajGzpVl6S$eb67JwlKbhjSPauiHuGE0HFo/+L/lcrQVifbzUzyK4M=', '2018-11-10 00:20:43.764924', 0, 'camado', 'José Amado', 'Carrera Marín', 'notiene@notiene.com', 0, 1, '2018-11-09 14:59:56.081314', 0),
(28, 'pbkdf2_sha256$120000$Yy8cevWicNcC$1H5/lh3s1uUOK1yd/v5CHCXyZzwhAqzWO8OGW09F6QM=', NULL, 0, 'cherminio', 'Mario Herminio', 'Carrera Marín', 'notiene@notiene.com', 0, 1, '2018-11-09 15:01:47.102372', 0),
(29, 'pbkdf2_sha256$120000$QfF7Db8iqQsd$jsA8xjjTBICWmo0tIZMP8cT36WWWJ5MGvVg0u0zJRMw=', '2018-11-09 16:32:34.458379', 0, 'aluis', 'Luis', 'Abanto Paredes', 'notiene@notiene.com', 0, 1, '2018-11-09 15:03:32.860404', 0),
(30, 'pbkdf2_sha256$120000$W5HcsPTgdcfn$mFJxTgmdwwgg6u48PghUtC9rOHEwjX7RJnuvqRSi3V8=', NULL, 0, 'cde', 'Juan de la Cruz', 'Carrera Marín', 'notiene@notiene.com', 0, 1, '2018-11-09 15:05:27.095859', 0),
(31, 'pbkdf2_sha256$120000$gpbwOnm5fhY3$XjAqfAgUOfZcLBkwR1qLApobMj0l1URzcEAc0WxZM/o=', NULL, 0, 'sbernardo', 'Jesús Bernardo', 'Sanchez Paz', 'notiene@notiene.com', 0, 1, '2018-11-09 15:06:46.735515', 0),
(32, 'pbkdf2_sha256$120000$nlHtuoJHIv4i$VsmqSH0N8kfxf4JrSQyyhZgt7zknHVsGjjPkUGmm60c=', NULL, 0, 'clius', 'José Luis', 'Cordero del Pino', 'notiene@notiene.com', 0, 1, '2018-11-09 15:08:06.182836', 0),
(33, 'pbkdf2_sha256$120000$nGIrRbyZoISd$L1wDrTMQnxGbzRWTlchS1b6hiN7nO/lO/01MKAdyXOk=', NULL, 0, 'cdoraliza', 'Juana Doraliza', 'Castañeda Paredes', 'notiene@notiene.com', 0, 1, '2018-11-09 15:10:10.352674', 0),
(34, 'pbkdf2_sha256$120000$ykbWq916kq2U$Wuwk70cWtwSC2hMzdDR2x8ZNGeBjMrYFPtye0u7veVo=', '2018-11-09 16:34:34.860352', 0, 'crossana', 'Martha Rossana', 'Correa Cabanillas', 'notiene@notiene.com', 0, 1, '2018-11-09 15:11:13.680061', 0),
(35, 'pbkdf2_sha256$120000$ZW9hMKIkpOug$dCdVSNSW/gvRSbT3dXGqoZLNzGAqRa/u487LN1fhXXU=', NULL, 0, 'gceyner', 'Ceyner', 'Gonzáles Chuan', 'notiene@notiene.com', 0, 1, '2018-11-09 15:12:34.978591', 0),
(36, 'pbkdf2_sha256$120000$guWaDCVBJSjN$D9PBC1oXyP2xrmzujNyq9Qm1RS3cKq5idZqn3M5dYrc=', NULL, 0, 'nronnaly', 'Sonia Ronnaly', 'Narva Barrantes', 'notiene@notiene.com', 0, 1, '2018-11-09 15:13:54.716408', 0),
(37, 'pbkdf2_sha256$120000$dmLTDQNpK7qV$TKpeFJXjOC2M5qRM/+ClIdAqzrIKbCZZKZFUomrLiyE=', NULL, 0, 'bfelix', 'Segundo Felix', 'Briones Acosta', 'notiene@notiene.com', 0, 1, '2018-11-09 15:14:41.537940', 0),
(38, 'pbkdf2_sha256$120000$SeLjE3PFbNZP$KLMC23lBiNxCDuo7qUiMKkgGHdHOdT47+jZ593ErqEk=', NULL, 0, 'cwilmer', 'José Wilmer', 'Cotrina Olortigui', 'notiene@notiene.com', 0, 1, '2018-11-09 15:15:32.526384', 0),
(39, 'pbkdf2_sha256$120000$2SkN5FCew83h$5RIWoOThXn69EZ6mnIVLtkX1qlRmnuzw4uXtAn3PiS8=', NULL, 0, 'cbalvina', 'Balvina', 'Córdova Mondragón', 'notiene@notiene.com', 0, 1, '2018-11-09 15:16:48.559912', 0),
(40, 'pbkdf2_sha256$120000$ojJXfgaCkF8k$YgtsYA9t5pUUF5guCJScVwaKni8Kjnp8X6VNE7xOpjc=', NULL, 0, 'crafael', 'Nelson Rafael', 'Castañeda Muñoz', 'notiene@notiene.com', 0, 1, '2018-11-09 15:17:48.920319', 0),
(41, 'pbkdf2_sha256$120000$XfnajZm4kPSE$FE8m1uagELFgiRzvQitSMA6efRy7bxHFQia5KSys78k=', NULL, 0, 'lelizabet', 'Dominga Elizabet', 'Lezama Mendoza', 'notiene@notiene.com', 0, 1, '2018-11-09 15:18:45.269044', 0),
(42, 'pbkdf2_sha256$120000$rgpEhRLQ9jiN$TtgNoCPUiUj36r3ikv3dNsvELy9E03ZYrhB3bvxm760=', NULL, 0, 'oclaudio', 'Segundo Claudio', 'Olortegui Acosta', 'notiene@notiene.com', 0, 1, '2018-11-09 15:19:37.676536', 0),
(43, 'pbkdf2_sha256$120000$mwBCDUSZatDP$Hso82yEhx7+ar4N31l1+yMUBxRsNtlZuQCAK4wH8zEo=', NULL, 0, 'ctomasa', 'Regina Tomasa', 'Castañeda Muñoz', 'notiene@notiene.com', 0, 1, '2018-11-09 15:22:32.325427', 0),
(44, 'pbkdf2_sha256$120000$MOvbBDcWjaKv$gdQQptSCtfc1bnbvl08lgPo0kUKDE74TnhbpuS0AGcU=', NULL, 0, 'scelestino', 'José Celestino', 'Sanchez Vargas', 'notiene@notiene.com', 0, 1, '2018-11-09 15:23:38.166565', 0),
(45, 'pbkdf2_sha256$120000$YQ8wJ5lsuNqN$VRFatqDkRzPhA1ZG7KWEWm1t4wUkYs74+iVwfrfV2Wc=', NULL, 0, 'aeligio', 'Eligio', 'Abanto Castañeda', 'notiene@notiene.com', 0, 1, '2018-11-09 15:24:56.902203', 0),
(46, 'pbkdf2_sha256$120000$VeJz3vTrIE7f$/aQpEjVkcqhpUl0WCIv4Auu5/w9Hq393X/5qiZsoZlA=', NULL, 0, 'myaneth', 'Any Yaneth', 'Mendoza Castañeda', 'notiene@notiene.com', 0, 1, '2018-11-09 15:26:08.723176', 0),
(47, 'pbkdf2_sha256$120000$VXzIjZ6Y1wCu$/z//ME9g52cbpnqlIyWReMg2qcI8gxBKu3gCPgyg4a0=', NULL, 0, 'bjesus', 'Jesús', 'Briones Acosta', 'notiene@notiene.com', 0, 1, '2018-11-09 15:26:58.702890', 0),
(48, 'pbkdf2_sha256$120000$MGhK1keZlJEt$jnjyHFuJvtvmizozymwSsV0wMhawXLGJVjtdNVin51w=', NULL, 0, 'pfelicita', 'Felicita', 'Perez Sanchez', 'notiene@notiene.com', 0, 1, '2018-11-09 15:27:52.514221', 0),
(49, 'pbkdf2_sha256$120000$Y8lnrimOxtGr$FCqtPfc6YxTWLdqd7XuLhh48lVIGCHUZ00aUjC6Lijk=', NULL, 0, 'bjose', 'José Antonio', 'Balarezo Rocha', 'notiene@notiene.com', 0, 1, '2018-11-09 15:29:11.436154', 0),
(50, 'pbkdf2_sha256$120000$FAEvqDn1sHiE$xDste3553KgrBKk4Is95uDcEMkd2HbI8ZVOxi0V2adI=', NULL, 0, 'vmaria', 'María Enma', 'Vega Rivera', 'notiene@notiene.com', 0, 1, '2018-11-09 15:30:02.611333', 0),
(51, 'pbkdf2_sha256$120000$3ifBP0dgDqRK$JhU5clF+VqrDpi5YnrcTklpjrGNAYNl9/YLJ++C1/gI=', '2018-11-10 18:20:49.372742', 0, 'mgraciano', 'Graciano', 'Mendoza Ruiz', 'notiene@notiene.com', 0, 1, '2018-11-09 15:30:46.981390', 0),
(52, 'pbkdf2_sha256$120000$8wiF1CdD7OE1$8E3JI5YtrXAMW8wllhtzFovRIec8zVaGhTlKVaukqHo=', NULL, 0, 'sinocente', 'Inocente', 'Sanchez Quiroz', 'notiene@notiene.com', 0, 1, '2018-11-09 18:30:28.478269', 0),
(53, 'pbkdf2_sha256$120000$Mz4BjOJ32Ve4$aiSEUYfnteXVyfqLEt3giTHtBlLNyOgsP479KZqnSJE=', NULL, 0, 'cinocencio', 'Aldemar Inocencio', 'Cotrina Castañeda', 'notiene@notiene.com', 0, 1, '2018-11-09 18:33:21.150267', 0),
(54, 'pbkdf2_sha256$120000$d4ok1ub1J9Ra$v/sepUVut57UK7rRjJdyHtbVcHAcRziBw/K+IDGumXA=', NULL, 0, 'rwilmer', 'Segundo Wilmer', 'Romero Mendoza', 'notiene@notiene.com', 0, 1, '2018-11-09 18:34:49.949350', 0),
(55, 'pbkdf2_sha256$120000$HN4ZcKbVRWti$19mKSj0Ego94QxQSkHXJAiZ9IaJKYeTQl5Dj2Oaui98=', NULL, 0, 'cgilberto', 'Diego Gilberto', 'Cieza Padilla', 'notiene@notiene.com', 0, 1, '2018-11-09 18:36:21.156040', 0),
(56, 'pbkdf2_sha256$120000$h2R5i5WcVtxS$HGbel8lG+0+vikdpoRI6cg9YfTIAJBriMH9HtfPpCPQ=', NULL, 0, 'aseverino', 'Valentin Severino', 'Abanto Paredes', 'notiene@notiene.com', 0, 1, '2018-11-09 18:37:55.103394', 0),
(57, 'pbkdf2_sha256$120000$9zv8XLbWfNfL$z7DEAD1B8wOoLQilOV/Ay2V2LInn9YcaS76FOyqu4lM=', NULL, 0, 'tgosvinda', 'Gosvinda', 'Tirado Sánchez', 'notiene@notiene.com', 0, 1, '2018-11-09 18:39:05.496553', 0),
(58, 'pbkdf2_sha256$120000$lUWERsWUVZyJ$Wb19eXs8vMxC92rFo/VTctrUtcWdxIY7JFuwspa8atI=', NULL, 0, 'mjesus', 'José Jesus', 'Muñoz Rios', 'notiene@notiene.com', 0, 1, '2018-11-09 18:40:08.863484', 0),
(59, 'pbkdf2_sha256$120000$GpJfmvqWzzOr$m/yYLHc+2G7twQD5/gt7jZMvGcvRo09FF4X8SRmZVMo=', NULL, 0, 'aestanislao', 'Ascensión Estanislao', 'Abanto Castillo', 'notiene@notiene.com', 0, 1, '2018-11-09 18:41:11.276064', 0),
(60, 'pbkdf2_sha256$120000$274HP86LIc8R$PfXdNagoAU1R1PAuY8VD903I2afvi3FCa34MM9N0HTM=', NULL, 0, 'fgerardo', 'Gerardo', 'Flores Chuan', 'notiene@notiene.com', 0, 1, '2018-11-09 18:42:16.005261', 0),
(61, 'pbkdf2_sha256$120000$xTwNDCJZqMZd$xRHrgKwstKQquSEuEJ6QCNe3JKmyyxhMuvroa5yS0+A=', NULL, 0, 'asimon', 'José Simón', 'Alarcón Marín', 'notiene@notiene.com', 0, 1, '2018-11-09 18:43:05.997933', 0),
(62, 'pbkdf2_sha256$120000$ZzXtIacJWpGY$j9kwsGsnimaodh+Z2mkPWVK5s6h7GJ8rKqP+MjJZVew=', NULL, 0, 'rmegidia', 'María Megidia', 'Rios Calderon', 'notiene@notiene.com', 0, 1, '2018-11-09 18:44:24.314631', 0),
(63, 'pbkdf2_sha256$120000$2AFjUfzEfOHu$5CycjvpiX+rOHOCH7TWR80ATeiDh61AxHM42G+q33HE=', NULL, 0, 'cberlyn', 'Denis Berlyn', 'Castañeda Canchez', 'notiene@notiene.com', 0, 1, '2018-11-09 18:45:34.128698', 0),
(64, 'pbkdf2_sha256$120000$ZZ0DS2VKwYUq$Sv4jDo7oFLJAPO4PGGf7WVfzOYqvOhW9ZE8wzV4qv7U=', NULL, 0, 'amaximo', 'Maximo', 'Alarcón Marín', 'notiene@notiene.com', 0, 1, '2018-11-09 18:46:19.428418', 0),
(65, 'pbkdf2_sha256$120000$UJ8HvG9stALA$Krift1EF1ZefAqX1h0rAOK062zKAVsfa2VRpX1Lq4r4=', NULL, 0, 'jteodosio', 'Teodosio', 'Jara Perez', 'notiene@notiene.com', 0, 1, '2018-11-09 18:47:09.199602', 0),
(66, 'pbkdf2_sha256$120000$f3rf13gRUEfn$Mpr2wEN+mbIpOZQ3znUt8X/DFCsXXM7tL5mxKMJ8GSU=', NULL, 0, 'afidel', 'Santos Fidel', 'Abanto Carrera', 'notiene@notiene.com', 0, 1, '2018-11-09 18:49:01.025532', 0),
(67, 'pbkdf2_sha256$120000$Sfhhl7g9PyEN$X65v+DrN3RZDZr7NwISv39BNaGblvUOxVeQA99N3O5s=', NULL, 0, 'nrenan', 'Renan', 'Novoa Arias', '', 0, 1, '2018-11-09 18:50:39.960766', 0),
(68, 'pbkdf2_sha256$120000$JRuBe78SHROs$HY9zOK2w+vSeutieyWRWw397hkbLpB712U6BR2bSWo0=', NULL, 0, 'casuncion', 'Asuncion', 'Cerdan Abanto', '', 0, 1, '2018-11-09 18:52:10.131686', 0),
(69, 'pbkdf2_sha256$120000$ZAUIQ75QiaeM$WPgGqauOeymkOj8jE7x8g0qUnecR7OgDmyU5rJY4/9g=', NULL, 0, 'awilmer', 'José Wilmer', 'Arias Rojas', '', 0, 1, '2018-11-09 18:54:06.483377', 0),
(70, 'pbkdf2_sha256$120000$1wjZITsF4BAO$R5bGeD7QgSteVHQW1XJiQpCfYVxkAPbk1X5QjyjeA80=', NULL, 0, 'fconcepcion', 'Sirilo Concepcion', 'Fabian Rojas', '', 0, 1, '2018-11-09 18:55:20.133483', 0),
(71, 'pbkdf2_sha256$120000$B6k7yToiIQyH$TM2ZIImDtufKFqQkekO1kRk1r3NlC+2l5GcBIkYJMno=', NULL, 0, 'bnapoleon', 'Ambrosio Napoleon', 'Briones Acosta', '', 0, 1, '2018-11-09 18:57:15.679434', 0),
(72, 'pbkdf2_sha256$120000$CcvLJke182q1$X9Bmlo0IV+jrjfX6C5y81u4rVMJrEEg5n8x7/UmC/bo=', NULL, 0, 'ddominica', 'María Dominica', 'Duran Ruiz de Rojas', '', 0, 1, '2018-11-09 18:58:22.330039', 0),
(73, 'pbkdf2_sha256$120000$LSjFrXlKJDGO$qadOj71sgyIm+f5ShhCofwx9vvsR4KqWuRznyXZUDLo=', NULL, 0, 'bjesusmanuel', 'Manuel Jesus', 'Bejarano Alvarado', '', 0, 1, '2018-11-09 19:01:46.502821', 0),
(74, 'pbkdf2_sha256$120000$u5jObtGht7rQ$r4KxcXz/L469naLnrfc8Sh7vg0ZbTLsnRu0Hzr87HQo=', NULL, 0, 'lantonio', 'Angel Antonio', 'Leiva Calderón', '', 0, 1, '2018-11-09 19:02:52.464175', 0),
(75, 'pbkdf2_sha256$120000$YLAcPAcBTNaU$q9eMF5BaH/vOnRUHj/ckMZyINVGStAxS0b3CF0Rtxww=', NULL, 0, 'lmaria', 'Ana María', 'Leiva Calderón', '', 0, 1, '2018-11-09 19:03:32.513172', 0),
(76, 'pbkdf2_sha256$120000$ps8fkT3r5Q2E$+KYo2a4lxkW/km0n5HHXY62lC+/r2q9J51kgMoSubeg=', NULL, 0, 'ladriana', 'Santa Adriana', 'Leiva Calderón', '', 0, 1, '2018-11-09 19:04:31.244012', 0),
(77, 'pbkdf2_sha256$120000$FENdvIJN1ASf$NyFX35+I8d8jG0Zxs7TCqzwjuMlAmUOIqtTxwLUGR5o=', NULL, 0, 'lsebastian', 'Fabio Sebastian', 'Leiva Calderón', '', 0, 1, '2018-11-09 19:05:34.676066', 0),
(78, 'pbkdf2_sha256$120000$5TmjSLUxZvfC$KIyWlH3Zt12UYY8Jg9KIBBS6goDcnK0p+kAfDdOCsgI=', NULL, 0, 'lavelino', 'Silverio Abelino', 'Leiva Calderón', '', 0, 1, '2018-11-09 19:06:18.249077', 0),
(79, 'pbkdf2_sha256$120000$zT7vaWlmieJg$Cn4ylOYZ1eE2qNXOwSwG4/Tx1wRaNv3Vu7lexOdN+SY=', NULL, 0, 'lconcepcion', 'Isolina Concepcion', 'Leiva Calderón', '', 0, 1, '2018-11-09 19:07:44.507826', 0),
(80, 'pbkdf2_sha256$120000$4HWnRKNFJk2A$VVkGfvTpHqUSae/Ig5NZXxamRBzOtLN6NrRvtJpncPI=', NULL, 0, 'lbautista', 'Juanita Bautista', 'Leiva Calderón', '', 0, 1, '2018-11-09 19:08:32.389179', 0),
(81, 'pbkdf2_sha256$120000$mbRtkzcQnVKK$TaC0WawLEXGafC64qcSJR1zKQGR9NbjZWJ2oVRKGmd0=', NULL, 0, 'rmarciano', 'Marciano', 'Rodriguez Calderón', '', 0, 1, '2018-11-09 19:09:17.546196', 0),
(82, 'pbkdf2_sha256$120000$vvUTcaQexKYb$mqbengS0IVmCeA43KlxCOmgb+YGPSLvydBdssLG9GXA=', NULL, 0, 'vhumberto', 'Humberto', 'Vasquez Morales', '', 0, 1, '2018-11-09 19:10:07.168433', 0),
(83, 'pbkdf2_sha256$120000$M5QHOGRtlqwW$9LJtYY8u4ADWd1S+IAd1tC0zQckZHV/2GYhRJg/JsVw=', NULL, 0, 'mandres', 'José Andres', 'Muñoz Jave', '', 0, 1, '2018-11-09 19:10:54.582555', 0),
(84, 'pbkdf2_sha256$120000$MP3JHmSs0bgd$KMqXPv9fEiIg6hl/tC+gWAEClJe/ZWws6UuEJJdGc0k=', NULL, 0, 'bemperatriz', 'Maritza Emperatriz', 'Briones Rojas', '', 0, 1, '2018-11-09 19:12:32.657495', 0),
(85, 'pbkdf2_sha256$120000$Wo52bRR3qh4H$mls8xeTPmk4zIeEjABqRYVCWauy56VWRii10CuI3OyM=', NULL, 0, 'qfredy', 'Epifanio Fredy', 'Quispe Lopez', '', 0, 1, '2018-11-09 19:13:32.902219', 0),
(86, 'pbkdf2_sha256$120000$BgZ5FqLNJpPb$fCdSlTu4zc4157htoAQCudns9lHVci0/r1Mv25fZfII=', NULL, 0, 'ateofilo', 'Esteban Teofilo', 'Aguilar Chavez', '', 0, 1, '2018-11-09 19:14:31.021972', 0),
(87, 'pbkdf2_sha256$120000$qfZcnmOeMNpz$DyC5lFvT10AeYm9a5f/2ClQOFydVBNlAMH05qUd9yhE=', NULL, 0, 'clodofico', 'Mario Lodofico', 'Chavez Arbildo', '', 0, 1, '2018-11-09 19:15:37.417835', 0),
(88, 'pbkdf2_sha256$120000$jQELDNR9PN2Q$/30C0N8Pq5YNQRoEBALLOGGM+KGeRH6Tsoe1e1tfiwk=', NULL, 0, 'gpedro', 'Pedro', 'Gonzales Carrera', '', 0, 1, '2018-11-09 19:16:23.745920', 0),
(89, 'pbkdf2_sha256$120000$FYQuDlc0ErzI$srx92OHuCdRJFjAX3zQRmaCIbyW2Jxp9nWy+5g1YnzM=', NULL, 0, 'ppercy', 'Hugo Percy', 'Palomino Quiroz', '', 0, 1, '2018-11-09 20:15:03.545118', 0),
(90, 'pbkdf2_sha256$120000$6h7lqzLW82RT$BjJpbg24vuOjVmoD24DJ5C3reiLcIXCnKs4HcV2wHBo=', NULL, 0, 'ljuan', 'Juan', 'Llanos Barrientos', '', 0, 1, '2018-11-09 20:16:00.157963', 0),
(91, 'pbkdf2_sha256$120000$xOzb9olTFaya$2A05iStcsImAm6CIgDqP//72P3E6Ohc6i6GiLerAtII=', NULL, 0, 'ajaime', 'Jaime', 'Abanto Asañero', '', 0, 1, '2018-11-09 20:17:04.099428', 0),
(92, 'pbkdf2_sha256$120000$WWMfXsOmm4oi$5iYEG2Oy++BCWp89CEz2OGovu0FjptF8eZHudOGFqD4=', NULL, 0, 'civan', 'Lelis Ivan', 'Carrera Izquierdo', '', 0, 1, '2018-11-09 20:18:09.081035', 0),
(93, 'pbkdf2_sha256$120000$NBvltqtHgYh5$94eKA1VIouPh631LIILidow6v3a2lcVjapAcBpQawKA=', NULL, 0, 'hbenito', 'José Benito', 'Honorio Cruzado', '', 0, 1, '2018-11-09 20:20:49.143099', 0),
(94, 'pbkdf2_sha256$120000$ZQwRfcWNENZG$x7Ry9Q31DSHcs8/J9CFnT5tC9JlMBv8bWtB+71WWlHg=', NULL, 0, 'oroger', 'Wilder Roger', 'Olortegui Castañeda', '', 0, 1, '2018-11-09 20:26:39.407711', 0),
(95, 'pbkdf2_sha256$120000$5pcZdy6UJJjc$7xw/3HL5EYrZZud8GV6yL3I993USjHWq988nNz43fkQ=', NULL, 0, 'lbenigno', 'Ludgerio Benigno', 'Lezama Rojas', '', 0, 1, '2018-11-09 20:27:34.515814', 0),
(96, 'pbkdf2_sha256$120000$bPF4hMvtkdGr$tfRxVOglua60NtJaAkNGCt0tohaLJonugWU20KDZAwE=', NULL, 0, 'cjhazzmin', 'Mara Jhazzmin', 'Cieza Briones', '', 0, 1, '2018-11-09 20:29:04.275164', 0),
(97, 'pbkdf2_sha256$120000$Di9eZwV4wlOA$MYmfVClTb8DV3rTExOlG3++PcKf9ekrNBKIZnu65sQ0=', NULL, 0, 'gsantos', 'Santos', 'Gregorio Guerrero', '', 0, 1, '2018-11-09 20:29:58.320641', 0),
(98, 'pbkdf2_sha256$120000$adYtJgx897cm$8Xkb3sBG14z+SiNxLO969uIpqYqQc3OUU4mPbn9n62Q=', NULL, 0, 'rmodesto', 'Modesto', 'Rojas Ruiz', '', 0, 1, '2018-11-09 20:31:09.394983', 0),
(99, 'pbkdf2_sha256$120000$qK0zX6dbhqPc$xgSBBWeDTA+OXPC2N4w8eLxPiYKflPyHqkkbMxjo+OU=', NULL, 0, 'cfelipe', 'Segundo Felipe', 'Castañeda Rabanal', '', 0, 1, '2018-11-09 20:32:02.207698', 0),
(100, 'pbkdf2_sha256$120000$BkmvUmPbBTXR$3EETq8pTcpGmER2/DDgwYV10mHxgFPaiH5X0Nfx06tA=', NULL, 0, 'qmarciano', 'Victor Marciano', 'Quiroz Cruzado', '', 0, 1, '2018-11-09 20:33:21.402495', 0),
(101, 'pbkdf2_sha256$120000$ygc4uKkJMinS$TqSJw/dFzFFPHq8ul81OZ4IHJVesnAh2ItD1X/8yMMg=', '2019-02-14 00:36:46.985589', 0, 'cfranklin', 'Robert Franklin', 'Cotrina Lezama', '', 0, 1, '2018-11-09 20:34:24.898749', 41957768),
(102, 'pbkdf2_sha256$120000$rRjxEBOWlpUs$4h2w4rHohS0UxpwCSm8GGyF5OX4td+W4OBsP+W2k3HM=', NULL, 0, 'sjesus', 'Jhonell Jesus', 'Sanchez Muñoz', '', 0, 1, '2018-11-09 20:35:43.758592', 0),
(103, 'pbkdf2_sha256$120000$vx5VBHoHfMEa$H4xL65xmqQ6TG6+ccc34tgbs79kg0P6JyqKCr2oBsxg=', NULL, 0, 'moctavio', 'Felix Octavio', 'Muñoz Pinedo', '', 0, 1, '2018-11-09 20:36:32.087298', 0),
(104, 'pbkdf2_sha256$120000$ksVLht2zVLF4$dSitxu5bLeFZ6TJO/ozmVfCJcpgacc9vdXH7tNkF/No=', NULL, 0, 'sdavid', 'Wilder David', 'Sanchez Paz', '', 0, 1, '2018-11-09 20:37:26.244004', 0),
(105, 'pbkdf2_sha256$120000$T8ZHNhBDqJpb$bxhwYT0ZW4CeEA/GQ+pgrS7tF6loPE7BHOLWjkVVJ10=', NULL, 0, 'draul', 'Kevin Raul', 'Suclupe Bazan', '', 0, 1, '2018-11-09 20:38:21.924223', 0),
(106, 'pbkdf2_sha256$120000$WWLhhPPKzO2p$C2Yy+XdGZM6Cm/Uib3eXwq6IdwoYbLrIbcE2WUGFXA8=', NULL, 0, 'scarlos', 'Jean Carlos', 'Sanchez Muñoz', '', 0, 1, '2018-11-09 20:39:04.455651', 0),
(107, 'pbkdf2_sha256$120000$DH8f1jHmpmcH$63dsJFXHSFD/c8t/TxVIkan8yiz4f8LtMsQ8VkRGugs=', NULL, 0, 'camelia', 'Amelia', 'Calderón Acevedo', '', 0, 1, '2018-11-09 20:39:56.018196', 0),
(108, 'pbkdf2_sha256$120000$v06fT1gJqId3$lmQNdmOfSobSH1P39hWEorh/Iyn3vVce8wEboB5vfjs=', NULL, 0, 'uignacio', 'José Ignacio', 'Urbina Huaccha', '', 0, 1, '2018-11-09 20:41:14.887206', 0),
(109, 'pbkdf2_sha256$120000$BnpGejFDwmFp$JRQms7qn7HWyoM04lba819A55m00r4SL006Fi1zSpKQ=', NULL, 0, 'talexander', 'Alexander', 'Torres Jimenez', '', 0, 1, '2018-11-09 20:43:47.882841', 0),
(110, 'pbkdf2_sha256$120000$KNhthzi8VHEh$DHZhULPUudWYBq/HhVqazSyxi3CnUrbTHJwUZS10r1Y=', NULL, 0, 'saldemar', 'Joel Aldemar', 'Sanchez Paredes', '', 0, 1, '2018-11-09 20:44:36.473671', 0),
(111, 'pbkdf2_sha256$120000$F3nnooYqWtZ8$FOGMaYBG00jvVqvSaAEMVRgT7iHoAvN28dxf7vd7evU=', NULL, 0, 'rdavid', 'Segundo David', 'Rojas Ruiz', '', 0, 1, '2018-11-09 20:46:31.662006', 0),
(112, 'pbkdf2_sha256$120000$r8JMLKInsR06$Os4HKvWDHFfftsjvJJcfs8m2IcNwXW7ipjbHuzzI+3I=', NULL, 0, 'ysegunda', 'María Segunda Juana', 'Yzquierdo Huaman', '', 0, 1, '2018-11-09 20:47:48.321481', 0),
(113, 'pbkdf2_sha256$120000$DsumAqgCIhvd$n0XBmvMq6lqb1S3t1P4QI7pYdWiE7qyqYIpNCD14YVc=', NULL, 0, 'mfelicita', 'Felicita', 'Muñoz Pinedo', '', 0, 1, '2018-11-09 20:49:01.809808', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_groups`
--

CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_user_permissions`
--

CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_user_user_permissions`
--

INSERT INTO `auth_user_user_permissions` (`id`, `user_id`, `permission_id`) VALUES
(2, 2, 137),
(1, 3, 138);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `canal`
--

CREATE TABLE `canal` (
  `id_canal` int(11) NOT NULL,
  `nombre` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `tamano` double DEFAULT NULL,
  `ubicacion` varchar(45) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `canal`
--

INSERT INTO `canal` (`id_canal`, `nombre`, `tamano`, `ubicacion`) VALUES
(2, 'Ramal 1', 2, 'Canal Madre'),
(3, 'Ramal 2', 4, 'Continuación del canal madre'),
(4, 'Ramal 3', 1.8, 'Canal Madre'),
(5, 'Ramal 4', 3.1, 'parte del ramal 3'),
(6, 'Ramal 5', 1.2, 'parte del ramal 3');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caudal`
--

CREATE TABLE `caudal` (
  `id_caudal` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `nivel` int(11) DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `caudal`
--

INSERT INTO `caudal` (`id_caudal`, `id_canal`, `fecha`, `nivel`, `descripcion`) VALUES
(1, 2, '2018-11-07 00:00:00', 5, 'Descripción'),
(2, 3, '2018-11-07 00:00:00', 2, 'Descripción'),
(3, 4, '2018-11-07 00:00:00', 1, 'Descripción'),
(4, 5, '2018-11-07 00:00:00', 0, 'Descripción'),
(5, 6, '2018-11-07 00:00:00', 5, 'Descripción'),
(6, 2, '2018-11-13 00:00:00', 5, 'Descripción'),
(7, 3, '2018-11-13 00:00:00', 0, 'Descripción'),
(8, 4, '2018-11-13 00:00:00', 0, 'Descripción'),
(9, 5, '2018-11-13 00:00:00', 5, 'Descripción'),
(10, 6, '2018-11-13 00:00:00', 0, 'Descripción'),
(11, 2, '2018-10-24 00:00:00', 0, 'Descripción'),
(12, 3, '2018-10-24 00:00:00', 5, 'Descripción'),
(13, 4, '2018-10-24 00:00:00', 5, 'Descripción'),
(14, 5, '2018-10-24 00:00:00', 0, 'Descripción'),
(15, 6, '2018-10-24 00:00:00', 0, 'Descripción');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comite`
--

CREATE TABLE `comite` (
  `id_comite` int(11) NOT NULL,
  `nombre` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(200) COLLATE hp8_bin DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobante`
--

CREATE TABLE `comprobante` (
  `id_comprobante` int(11) NOT NULL,
  `id_talonario` int(11) NOT NULL,
  `ticket_numero` int(11) DEFAULT NULL,
  `concepto` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `monto` double DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comp_multa`
--

CREATE TABLE `comp_multa` (
  `id_comp_multa` int(11) NOT NULL,
  `id_comprobante` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comp_orden`
--

CREATE TABLE `comp_orden` (
  `id_comp_orden` int(11) NOT NULL,
  `id_comprobante` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_personales`
--

CREATE TABLE `datos_personales` (
  `id_datos_personales` int(11) NOT NULL,
  `dni` char(8) COLLATE hp8_bin DEFAULT NULL,
  `alias` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `sexo` char(1) COLLATE hp8_bin DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `telefono` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `celular` char(13) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `datos_personales`
--

INSERT INTO `datos_personales` (`id_datos_personales`, `dni`, `alias`, `sexo`, `fecha_nacimiento`, `telefono`, `celular`, `foto`, `id_auth_user`) VALUES
(1, '76583884', 'Nene', 'M', '1994-11-30', NULL, '927088981', 'photos/20180508_165334.jpg', 1),
(5, '27920554', 'Ramón', 'M', NULL, NULL, NULL, 'photos/cuenta1.jpg', 14),
(6, '44500169', NULL, 'M', NULL, NULL, NULL, 'photos/cuenta1_HAhCDFn.jpg', 22);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `destajo`
--

CREATE TABLE `destajo` (
  `id_destajo` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `tamano` double DEFAULT NULL,
  `num_orden` int(11) DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `det_limpieza`
--

CREATE TABLE `det_limpieza` (
  `id_det_limpieza` int(11) NOT NULL,
  `id_destajo` int(11) DEFAULT NULL,
  `id_limpieza` int(11) DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `det_lista`
--

CREATE TABLE `det_lista` (
  `id_det_lista` int(11) NOT NULL,
  `id_lista` int(11) DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL,
  `cargo` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direccion`
--

CREATE TABLE `direccion` (
  `id_direccion` int(11) NOT NULL,
  `id_datos_personales` int(11) DEFAULT NULL,
  `pais` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `cod_postal` int(11) DEFAULT NULL,
  `departamento` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `provinciaa` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `distrito` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `dir_larga` varchar(100) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE hp8_bin,
  `object_repr` varchar(200) COLLATE hp8_bin NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL,
  `change_message` longtext COLLATE hp8_bin NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(1, '2018-10-24 14:00:45.888346', '3', 'Canalero', 2, '[{\"changed\": {\"fields\": [\"user_permissions\"]}}]', 4, 1),
(2, '2018-10-24 14:00:56.459897', '2', 'Presidente', 2, '[{\"changed\": {\"fields\": [\"user_permissions\"]}}]', 4, 1),
(3, '2018-10-27 03:58:43.027307', '9', 'Shando', 3, '', 4, 1),
(4, '2018-11-09 00:07:50.198552', '11', 'Geral', 3, '', 4, 1),
(5, '2018-11-09 00:07:50.241524', '6', 'Gerardo', 3, '', 4, 1),
(6, '2018-11-09 00:07:50.298626', '12', 'Maria', 3, '', 4, 1),
(7, '2018-11-09 00:07:50.357250', '8', 'Mario', 3, '', 4, 1),
(8, '2018-11-09 00:07:50.379190', '7', 'Micaela', 3, '', 4, 1),
(9, '2018-11-09 00:07:50.390657', '10', 'Shando', 3, '', 4, 1),
(10, '2018-11-09 00:07:50.401338', '4', 'Tany', 3, '', 4, 1),
(11, '2018-11-09 00:13:39.848561', '11', 'Geral', 3, '', 4, 1),
(12, '2018-11-09 00:13:39.915356', '6', 'Gerardo', 3, '', 4, 1),
(13, '2018-11-09 00:13:39.927295', '12', 'Maria', 3, '', 4, 1),
(14, '2018-11-09 00:13:39.956216', '8', 'Mario', 3, '', 4, 1),
(15, '2018-11-09 00:13:40.048968', '7', 'Micaela', 3, '', 4, 1),
(16, '2018-11-09 00:13:40.059939', '10', 'Shando', 3, '', 4, 1),
(17, '2018-11-09 00:13:40.081880', '4', 'Tany', 3, '', 4, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) COLLATE hp8_bin NOT NULL,
  `model` varchar(100) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(1, 'admin', 'logentry'),
(3, 'auth', 'group'),
(2, 'auth', 'permission'),
(4, 'auth', 'user'),
(5, 'contenttypes', 'contenttype'),
(7, 'inicio', 'acceso'),
(29, 'inicio', 'agendaasamblea'),
(30, 'inicio', 'archivosparcela'),
(8, 'inicio', 'asamblea'),
(9, 'inicio', 'asistencia'),
(31, 'inicio', 'authgroup'),
(32, 'inicio', 'authgrouppermissions'),
(33, 'inicio', 'authpermission'),
(34, 'inicio', 'authuser'),
(35, 'inicio', 'authusergroups'),
(36, 'inicio', 'authuseruserpermissions'),
(10, 'inicio', 'canal'),
(11, 'inicio', 'caudal'),
(12, 'inicio', 'comite'),
(43, 'inicio', 'compmulta'),
(44, 'inicio', 'comporden'),
(13, 'inicio', 'comprobante'),
(37, 'inicio', 'datospersonales'),
(14, 'inicio', 'destajo'),
(15, 'inicio', 'detlimpieza'),
(16, 'inicio', 'detlista'),
(17, 'inicio', 'direccion'),
(38, 'inicio', 'djangoadminlog'),
(39, 'inicio', 'djangocontenttype'),
(40, 'inicio', 'djangomigrations'),
(41, 'inicio', 'djangosession'),
(42, 'inicio', 'hojaasistencia'),
(18, 'inicio', 'limpieza'),
(19, 'inicio', 'lista'),
(20, 'inicio', 'multa'),
(45, 'inicio', 'multaasistencia'),
(46, 'inicio', 'multalimpia'),
(47, 'inicio', 'multaorden'),
(21, 'inicio', 'noticia'),
(22, 'inicio', 'obra'),
(23, 'inicio', 'ordenriego'),
(24, 'inicio', 'parcela'),
(25, 'inicio', 'persona'),
(26, 'inicio', 'reparto'),
(27, 'inicio', 'talonario'),
(28, 'inicio', 'usuario'),
(6, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` int(11) NOT NULL,
  `app` varchar(255) COLLATE hp8_bin NOT NULL,
  `name` varchar(255) COLLATE hp8_bin NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2018-10-24 13:25:42.787826'),
(2, 'auth', '0001_initial', '2018-10-24 13:25:50.201390'),
(3, 'admin', '0001_initial', '2018-10-24 13:25:51.904184'),
(4, 'admin', '0002_logentry_remove_auto_add', '2018-10-24 13:25:51.967732'),
(5, 'admin', '0003_logentry_add_action_flag_choices', '2018-10-24 13:25:52.049807'),
(6, 'contenttypes', '0002_remove_content_type_name', '2018-10-24 13:25:52.803253'),
(7, 'auth', '0002_alter_permission_name_max_length', '2018-10-24 13:25:53.531835'),
(8, 'auth', '0003_alter_user_email_max_length', '2018-10-24 13:25:54.222407'),
(9, 'auth', '0004_alter_user_username_opts', '2018-10-24 13:25:54.320867'),
(10, 'auth', '0005_alter_user_last_login_null', '2018-10-24 13:25:54.892151'),
(11, 'auth', '0006_require_contenttypes_0002', '2018-10-24 13:25:54.941310'),
(12, 'auth', '0007_alter_validators_add_error_messages', '2018-10-24 13:25:55.004515'),
(13, 'auth', '0008_alter_user_username_max_length', '2018-10-24 13:25:55.554831'),
(14, 'auth', '0009_alter_user_last_name_max_length', '2018-10-24 13:25:56.145624'),
(15, 'sessions', '0001_initial', '2018-10-24 13:25:57.080944'),
(16, 'usuario', '0001_initial', '2018-10-24 14:00:09.350040'),
(17, 'canalero', '0001_initial', '2018-10-24 14:00:09.634887'),
(18, 'usuario', '0002_auto_20180912_1116', '2018-10-24 14:00:12.077464'),
(19, 'usuario', '0003_parcela', '2018-10-24 14:00:13.002116'),
(20, 'usuario', '0004_auto_20181011_1038', '2018-10-24 14:00:14.532277'),
(21, 'canalero', '0002_delete_reparto', '2018-10-24 14:00:14.877007'),
(22, 'inicio', '0001_initial', '2018-10-24 14:00:15.074979'),
(23, 'inicio', '0002_agendaasamblea_archivosparcela_authgroup_authgrouppermissions_authpermission_authuser_authusergroups', '2018-10-24 14:00:15.189204'),
(24, 'inicio', '0003_auto_20181017_1014', '2018-10-24 14:00:15.207290'),
(25, 'inicio', '0004_auto_20181017_1453', '2018-10-24 14:00:15.228086'),
(26, 'inicio', '0005_compmulta_comporden_multaasistencia_multalimpia_multaorden', '2018-10-24 22:39:18.896977');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) COLLATE hp8_bin NOT NULL,
  `session_data` longtext COLLATE hp8_bin NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_session`
--

INSERT INTO `django_session` (`session_key`, `session_data`, `expire_date`) VALUES
('1ccvzwq4pslk9ndabwh2f7hvfsndob8i', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:35:58.926615'),
('1y5l67o1fmpxhaikumu5qj6r6mr2vmmp', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-02-28 00:53:35.679803'),
('3ynq9lanaqjfyvonmelghvsibh217o4u', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 05:55:23.754279'),
('4da8kkkeky53mglf3i0spz7r84ku3ts7', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:52:01.362211'),
('4fzqoitfrcwiylye5rs88fuwa6nsq0yf', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 01:34:12.307928'),
('4hsrjhngfddtsab470dt96a9moihr8x8', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:17:14.954273'),
('5t85ym829tstif20vlq49btj6aifvnpw', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-11-28 03:37:10.599686'),
('614iv2rnzoq295iiad7xb8ceek627zm5', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 06:04:09.693747'),
('65upvsxujm7t3y59qb7oxuew3ph1lbo4', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:47:26.986865'),
('6j921vm0alcg0wz2k08lpgi4p75gx1zm', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:32:40.030620'),
('75ckoeeh0w8vxzkgruxln3qlbt0788b5', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:13:34.211631'),
('7xqu9lccef9immkw1916gcpn2wq32p7e', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:45:29.740744'),
('8b5ngjr744ffw086fa7g60hvyqe5uvyz', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-02 02:35:43.897838'),
('aaw7rbb3gludd0shf70dppejvwrxvuin', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-03-23 03:07:20.731862'),
('asmv0z9zzrro17q0ukvl0em59gsdqjxe', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:15:10.598969'),
('avvx4stu9fbd0ya2e2edns6e8t1ycatf', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:04:39.247484'),
('b5w8bq7mc45ngk29ure7vbso5vja6gfg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:12:34.787156'),
('bq9dq161ug15j8p9pnpc4zyxyqahbk6j', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-05-04 19:09:01.366379'),
('c56b5fzbkcobbiy105296r8twyq43w6o', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:12:16.006079'),
('cjotbhnry6ctyrecq5mhdkvrouczn0pw', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-16 16:32:36.082730'),
('clydvrz26t9rd03wltkflqjvh0nykwjc', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 14:17:19.304949'),
('d1p4cqa180eqzbgi4y5emxvwce9iw8zr', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-19 01:30:41.004640'),
('fjolhbix1iwfpn1byd21h7pwpkrklpek', 'ZjE4ZTg4OWVhMjc0MTg0NTUxMGU2YjcyZWZiZDk5MmYxYTE1NWMyNjp7fQ==', '2018-11-07 22:28:02.214088'),
('gece0q5sinynjff2gmhoc0baky6ffc1w', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:27:13.596974'),
('i13iymtpnpmegzvapg99zhed45fm5jpe', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-29 00:25:54.110431'),
('iu9ni74ux5u026buq34zrqu4496s34q6', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-07 08:56:02.424126'),
('ix0j23u5ds65tp49rrhzhf3rrp2ayn2k', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:29:59.709324'),
('j3z2icr2fi74lr9swt8oq3xbvxx0a5cv', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:14:33.993703'),
('kmvgz3o5rioilblg3wwqur6im3o86ozb', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 04:51:24.185699'),
('ko7mvmbtj3tt39pcy9hg7l27dvfj21h7', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:28:05.671350'),
('kzhakshs3t1ks0d9r3h3qa7plsxkyuwj', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:30:11.007831'),
('l6zjj5grboiwadmdsr98lmf0ryn1a4p8', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:28:45.828260'),
('mlnbjat13hrgolefic8za87mpq271ga3', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:47:46.294384'),
('n1ksidqyjs1ojn327k9ixficft3jfjpq', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-06-16 06:34:28.934645'),
('n3hk15v3i4v5vtxkd5takriw0ln1yei4', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:32:08.020249'),
('npbcewt24ssfsgy5re407fv2hvsvkhe6', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:05:20.808965'),
('nqpnbnnbwtrt1plqgw5me8tw162qw6bg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-05-04 18:54:58.265816'),
('nrbtckgzfon5yl65yp2nnvghzbjtgw5d', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:49:41.953863'),
('nuasrsi6kalukk6ot8uj1wlzcuj9qg8a', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:35:52.642609'),
('o4rv64adiy0olc6xlb77jinfzvut4olp', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-09 04:20:52.397983'),
('pezgbhr4pqyass4edmqhe4hgqphyl94x', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 13:50:51.058756'),
('pn30dgpr1dyvxpdziq7p8dav5gq8xqql', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:02:30.554228'),
('pwqlgtqlp8i2w2uav0oir40qs6mu8x1g', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-05 02:40:25.191997'),
('qmnqakzfrg49ye887g4ic3uwjc01gt9t', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:18:06.539177'),
('rw7m078dt8bnggmqtb6kepytsrufvj3u', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-18 01:24:21.106950'),
('s2vtchd00l4hocj4loortqkagthfp3qg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:40:08.345137'),
('sfe6vpnm4vv1oatm5nnh6l0vb93cs9bm', 'MjExMTY5YTQ3MGViM2I3NTI5MmQ1YWMxYjZmYjIzZmRiMDkwYzZlMTp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI0OGUyYzk3Njg0ZmUzNjQ4YmE1NGVhYzEyNTEwODI4OWZhM2I0OGMxIn0=', '2019-02-20 02:26:10.705346'),
('tdxgz5nug9hyawlcb3rh8hhnhqyrat43', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:46:13.587812'),
('ui15lko0el2or5x1193gd389wh8xt7nd', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-08-01 12:06:42.755118'),
('v4bbru1ugu74x6oihr7sk3cpdk3q9v7g', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-17 23:58:57.924970'),
('vlugoy1p981fb3nxk2serk41onhsp199', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 05:45:57.261107'),
('wa7fjgv2og19w50m1ks7plh7cw3swj2n', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:00:43.880475'),
('xi764xzbb20hedqwt2jq2y0if3u8otdl', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:43:17.751521'),
('xqxbd573v0b1ikauesm824zhjf7zzwtm', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:50:35.934963'),
('yck1pt7iautzdlv9d8rdlwdsfzivaaqd', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:24:00.185875'),
('yxzljq9g20yh5fynbmr4ybsfutn3i80p', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 00:21:48.663705'),
('zeqa0stzqx95gactvjjzkkrtq6wff3eh', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:27:04.594284'),
('zrcdlv9wu3elsgkxfl573ygsr145boo7', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:24:10.834865');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `hoja_asistencia`
--

CREATE TABLE `hoja_asistencia` (
  `id_hoja_asistencia` int(11) NOT NULL,
  `id_asamblea` int(11) NOT NULL,
  `id_auth_user` int(11) NOT NULL,
  `estado` varchar(15) COLLATE hp8_bin NOT NULL,
  `hora` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `hoja_asistencia`
--

INSERT INTO `hoja_asistencia` (`id_hoja_asistencia`, `id_asamblea`, `id_auth_user`, `estado`, `hora`) VALUES
(1049, 14, 27, '0', '2000-01-01 00:00:01'),
(1050, 14, 28, '0', '2000-01-01 00:00:01'),
(1051, 14, 109, '0', '2000-01-01 00:00:01'),
(1052, 14, 29, '0', '2000-01-01 00:00:01'),
(1053, 1, 14, '0', '2000-01-01 00:00:01'),
(1054, 1, 14, '0', '2000-01-01 00:00:01'),
(1055, 1, 22, '0', '2000-01-01 00:00:01'),
(1056, 1, 23, '0', '2000-01-01 00:00:01'),
(1057, 1, 24, '0', '2000-01-01 00:00:01'),
(1058, 1, 25, '0', '2000-01-01 00:00:01'),
(1059, 1, 26, '0', '2000-01-01 00:00:01'),
(1060, 1, 27, '0', '2000-01-01 00:00:01'),
(1061, 1, 28, '0', '2000-01-01 00:00:01'),
(1062, 1, 29, '0', '2000-01-01 00:00:01'),
(1063, 1, 30, '0', '2000-01-01 00:00:01'),
(1064, 1, 31, '0', '2000-01-01 00:00:01'),
(1065, 1, 32, '0', '2000-01-01 00:00:01'),
(1066, 1, 33, '0', '2000-01-01 00:00:01'),
(1067, 1, 34, '0', '2000-01-01 00:00:01'),
(1068, 1, 35, '0', '2000-01-01 00:00:01'),
(1069, 1, 36, '0', '2000-01-01 00:00:01'),
(1070, 1, 37, '0', '2000-01-01 00:00:01'),
(1071, 1, 38, '0', '2000-01-01 00:00:01'),
(1072, 1, 39, '0', '2000-01-01 00:00:01'),
(1073, 1, 40, '0', '2000-01-01 00:00:01'),
(1074, 1, 41, '0', '2000-01-01 00:00:01'),
(1075, 1, 42, '0', '2000-01-01 00:00:01'),
(1076, 1, 43, '0', '2000-01-01 00:00:01'),
(1077, 1, 44, '0', '2000-01-01 00:00:01'),
(1078, 1, 34, '0', '2000-01-01 00:00:01'),
(1079, 1, 45, '0', '2000-01-01 00:00:01'),
(1080, 1, 46, '0', '2000-01-01 00:00:01'),
(1081, 1, 47, '0', '2000-01-01 00:00:01'),
(1082, 1, 48, '0', '2000-01-01 00:00:01'),
(1083, 1, 49, '0', '2000-01-01 00:00:01'),
(1084, 1, 50, '0', '2000-01-01 00:00:01'),
(1085, 1, 51, '0', '2000-01-01 00:00:01'),
(1086, 1, 52, '0', '2000-01-01 00:00:01'),
(1087, 1, 53, '0', '2000-01-01 00:00:01'),
(1088, 1, 54, '0', '2000-01-01 00:00:01'),
(1089, 1, 55, '0', '2000-01-01 00:00:01'),
(1090, 1, 30, '0', '2000-01-01 00:00:01'),
(1091, 1, 56, '0', '2000-01-01 00:00:01'),
(1092, 1, 57, '0', '2000-01-01 00:00:01'),
(1093, 1, 58, '0', '2000-01-01 00:00:01'),
(1094, 1, 59, '0', '2000-01-01 00:00:01'),
(1095, 1, 60, '0', '2000-01-01 00:00:01'),
(1096, 1, 61, '0', '2000-01-01 00:00:01'),
(1097, 1, 62, '0', '2000-01-01 00:00:01'),
(1098, 1, 63, '0', '2000-01-01 00:00:01'),
(1099, 1, 64, '0', '2000-01-01 00:00:01'),
(1100, 1, 65, '0', '2000-01-01 00:00:01'),
(1101, 1, 26, '0', '2000-01-01 00:00:01'),
(1102, 1, 66, '0', '2000-01-01 00:00:01'),
(1103, 1, 66, '0', '2000-01-01 00:00:01'),
(1104, 1, 5, '0', '2000-01-01 00:00:01'),
(1105, 1, 67, '0', '2000-01-01 00:00:01'),
(1106, 1, 68, '0', '2000-01-01 00:00:01'),
(1107, 1, 39, '0', '2000-01-01 00:00:01'),
(1108, 1, 69, '0', '2000-01-01 00:00:01'),
(1109, 1, 70, '0', '2000-01-01 00:00:01'),
(1110, 1, 28, '0', '2000-01-01 00:00:01'),
(1111, 1, 37, '0', '2000-01-01 00:00:01'),
(1112, 1, 71, '0', '2000-01-01 00:00:01'),
(1113, 1, 72, '0', '2000-01-01 00:00:01'),
(1114, 1, 73, '0', '2000-01-01 00:00:01'),
(1115, 1, 74, '0', '2000-01-01 00:00:01'),
(1116, 1, 75, '0', '2000-01-01 00:00:01'),
(1117, 1, 76, '0', '2000-01-01 00:00:01'),
(1118, 1, 77, '0', '2000-01-01 00:00:01'),
(1119, 1, 78, '0', '2000-01-01 00:00:01'),
(1120, 1, 79, '0', '2000-01-01 00:00:01'),
(1121, 1, 80, '0', '2000-01-01 00:00:01'),
(1122, 1, 81, '0', '2000-01-01 00:00:01'),
(1123, 1, 82, '0', '2000-01-01 00:00:01'),
(1124, 1, 83, '0', '2000-01-01 00:00:01'),
(1125, 1, 84, '0', '2000-01-01 00:00:01'),
(1126, 1, 84, '0', '2000-01-01 00:00:01'),
(1127, 1, 85, '0', '2000-01-01 00:00:01'),
(1128, 1, 86, '0', '2000-01-01 00:00:01'),
(1129, 1, 87, '0', '2000-01-01 00:00:01'),
(1130, 1, 88, '0', '2000-01-01 00:00:01'),
(1131, 1, 2, '0', '2000-01-01 00:00:01'),
(1132, 1, 89, '0', '2000-01-01 00:00:01'),
(1133, 1, 90, '0', '2000-01-01 00:00:01'),
(1134, 1, 91, '0', '2000-01-01 00:00:01'),
(1135, 1, 27, '0', '2000-01-01 00:00:01'),
(1136, 1, 92, '0', '2000-01-01 00:00:01'),
(1137, 1, 93, '0', '2000-01-01 00:00:01'),
(1138, 1, 94, '0', '2000-01-01 00:00:01'),
(1139, 1, 95, '0', '2000-01-01 00:00:01'),
(1140, 1, 48, '0', '2000-01-01 00:00:01'),
(1141, 1, 96, '0', '2000-01-01 00:00:01'),
(1142, 1, 97, '0', '2000-01-01 00:00:01'),
(1143, 1, 84, '0', '2000-01-01 00:00:01'),
(1144, 1, 98, '0', '2000-01-01 00:00:01'),
(1145, 1, 99, '0', '2000-01-01 00:00:01'),
(1146, 1, 52, '0', '2000-01-01 00:00:01'),
(1147, 1, 41, '0', '2000-01-01 00:00:01'),
(1148, 1, 100, '0', '2000-01-01 00:00:01'),
(1149, 1, 101, '0', '2000-01-01 00:00:01'),
(1150, 1, 102, '0', '2000-01-01 00:00:01'),
(1151, 1, 103, '0', '2000-01-01 00:00:01'),
(1152, 1, 104, '0', '2000-01-01 00:00:01'),
(1153, 1, 105, '0', '2000-01-01 00:00:01'),
(1154, 1, 106, '0', '2000-01-01 00:00:01'),
(1155, 1, 107, '0', '2000-01-01 00:00:01'),
(1156, 1, 26, '0', '2000-01-01 00:00:01'),
(1157, 1, 108, '0', '2000-01-01 00:00:01'),
(1158, 1, 59, '0', '2000-01-01 00:00:01'),
(1159, 1, 109, '0', '2000-01-01 00:00:01'),
(1160, 1, 110, '0', '2000-01-01 00:00:01'),
(1161, 1, 38, '0', '2000-01-01 00:00:01'),
(1162, 1, 55, '0', '2000-01-01 00:00:01'),
(1163, 1, 111, '0', '2000-01-01 00:00:01'),
(1164, 1, 112, '0', '2000-01-01 00:00:01'),
(1165, 1, 113, '0', '2000-01-01 00:00:01'),
(1166, 1, 14, '0', '2000-01-01 00:00:01'),
(1167, 1, 14, '0', '2000-01-01 00:00:01'),
(1168, 1, 22, '0', '2000-01-01 00:00:01'),
(1169, 1, 23, '0', '2000-01-01 00:00:01'),
(1170, 1, 24, '0', '2000-01-01 00:00:01'),
(1171, 1, 25, '0', '2000-01-01 00:00:01'),
(1172, 1, 26, '0', '2000-01-01 00:00:01'),
(1173, 1, 27, '0', '2000-01-01 00:00:01'),
(1174, 1, 28, '0', '2000-01-01 00:00:01'),
(1175, 1, 29, '0', '2000-01-01 00:00:01'),
(1176, 1, 30, '0', '2000-01-01 00:00:01'),
(1177, 1, 31, '0', '2000-01-01 00:00:01'),
(1178, 1, 32, '0', '2000-01-01 00:00:01'),
(1179, 1, 33, '0', '2000-01-01 00:00:01'),
(1180, 1, 34, '0', '2000-01-01 00:00:01'),
(1181, 1, 35, '0', '2000-01-01 00:00:01'),
(1182, 1, 36, '0', '2000-01-01 00:00:01'),
(1183, 1, 37, '0', '2000-01-01 00:00:01'),
(1184, 1, 38, '0', '2000-01-01 00:00:01'),
(1185, 1, 39, '0', '2000-01-01 00:00:01'),
(1186, 1, 40, '0', '2000-01-01 00:00:01'),
(1187, 1, 41, '0', '2000-01-01 00:00:01'),
(1188, 1, 42, '0', '2000-01-01 00:00:01'),
(1189, 1, 43, '0', '2000-01-01 00:00:01'),
(1190, 1, 44, '0', '2000-01-01 00:00:01'),
(1191, 1, 34, '0', '2000-01-01 00:00:01'),
(1192, 1, 45, '0', '2000-01-01 00:00:01'),
(1193, 1, 46, '0', '2000-01-01 00:00:01'),
(1194, 1, 47, '0', '2000-01-01 00:00:01'),
(1195, 1, 48, '0', '2000-01-01 00:00:01'),
(1196, 1, 49, '0', '2000-01-01 00:00:01'),
(1197, 1, 50, '0', '2000-01-01 00:00:01'),
(1198, 1, 51, '0', '2000-01-01 00:00:01'),
(1199, 1, 52, '0', '2000-01-01 00:00:01'),
(1200, 1, 53, '0', '2000-01-01 00:00:01'),
(1201, 1, 54, '0', '2000-01-01 00:00:01'),
(1202, 1, 55, '0', '2000-01-01 00:00:01'),
(1203, 1, 30, '0', '2000-01-01 00:00:01'),
(1204, 1, 56, '0', '2000-01-01 00:00:01'),
(1205, 1, 57, '0', '2000-01-01 00:00:01'),
(1206, 1, 58, '0', '2000-01-01 00:00:01'),
(1207, 1, 59, '0', '2000-01-01 00:00:01'),
(1208, 1, 60, '0', '2000-01-01 00:00:01'),
(1209, 1, 61, '0', '2000-01-01 00:00:01'),
(1210, 1, 62, '0', '2000-01-01 00:00:01'),
(1211, 1, 63, '0', '2000-01-01 00:00:01'),
(1212, 1, 64, '0', '2000-01-01 00:00:01'),
(1213, 1, 65, '0', '2000-01-01 00:00:01'),
(1214, 1, 26, '0', '2000-01-01 00:00:01'),
(1215, 1, 66, '0', '2000-01-01 00:00:01'),
(1216, 1, 66, '0', '2000-01-01 00:00:01'),
(1217, 1, 5, '0', '2000-01-01 00:00:01'),
(1218, 1, 67, '0', '2000-01-01 00:00:01'),
(1219, 1, 68, '0', '2000-01-01 00:00:01'),
(1220, 1, 39, '0', '2000-01-01 00:00:01'),
(1221, 1, 69, '0', '2000-01-01 00:00:01'),
(1222, 1, 70, '0', '2000-01-01 00:00:01'),
(1223, 1, 28, '0', '2000-01-01 00:00:01'),
(1224, 1, 37, '0', '2000-01-01 00:00:01'),
(1225, 1, 71, '0', '2000-01-01 00:00:01'),
(1226, 1, 72, '0', '2000-01-01 00:00:01'),
(1227, 1, 73, '0', '2000-01-01 00:00:01'),
(1228, 1, 74, '0', '2000-01-01 00:00:01'),
(1229, 1, 75, '0', '2000-01-01 00:00:01'),
(1230, 1, 76, '0', '2000-01-01 00:00:01'),
(1231, 1, 77, '0', '2000-01-01 00:00:01'),
(1232, 1, 78, '0', '2000-01-01 00:00:01'),
(1233, 1, 79, '0', '2000-01-01 00:00:01'),
(1234, 1, 80, '0', '2000-01-01 00:00:01'),
(1235, 1, 81, '0', '2000-01-01 00:00:01'),
(1236, 1, 82, '0', '2000-01-01 00:00:01'),
(1237, 1, 83, '0', '2000-01-01 00:00:01'),
(1238, 1, 84, '0', '2000-01-01 00:00:01'),
(1239, 1, 84, '0', '2000-01-01 00:00:01'),
(1240, 1, 85, '0', '2000-01-01 00:00:01'),
(1241, 1, 86, '0', '2000-01-01 00:00:01'),
(1242, 1, 87, '0', '2000-01-01 00:00:01'),
(1243, 1, 88, '0', '2000-01-01 00:00:01'),
(1244, 1, 2, '0', '2000-01-01 00:00:01'),
(1245, 1, 89, '0', '2000-01-01 00:00:01'),
(1246, 1, 90, '0', '2000-01-01 00:00:01'),
(1247, 1, 91, '0', '2000-01-01 00:00:01'),
(1248, 1, 27, '0', '2000-01-01 00:00:01'),
(1249, 1, 92, '0', '2000-01-01 00:00:01'),
(1250, 1, 93, '0', '2000-01-01 00:00:01'),
(1251, 1, 94, '0', '2000-01-01 00:00:01'),
(1252, 1, 95, '0', '2000-01-01 00:00:01'),
(1253, 1, 48, '0', '2000-01-01 00:00:01'),
(1254, 1, 96, '0', '2000-01-01 00:00:01'),
(1255, 1, 97, '0', '2000-01-01 00:00:01'),
(1256, 1, 84, '0', '2000-01-01 00:00:01'),
(1257, 1, 98, '0', '2000-01-01 00:00:01'),
(1258, 1, 99, '0', '2000-01-01 00:00:01'),
(1259, 1, 52, '0', '2000-01-01 00:00:01'),
(1260, 1, 41, '0', '2000-01-01 00:00:01'),
(1261, 1, 100, '0', '2000-01-01 00:00:01'),
(1262, 1, 101, '0', '2000-01-01 00:00:01'),
(1263, 1, 102, '0', '2000-01-01 00:00:01'),
(1264, 1, 103, '0', '2000-01-01 00:00:01'),
(1265, 1, 104, '0', '2000-01-01 00:00:01'),
(1266, 1, 105, '0', '2000-01-01 00:00:01'),
(1267, 1, 106, '0', '2000-01-01 00:00:01'),
(1268, 1, 107, '0', '2000-01-01 00:00:01'),
(1269, 1, 26, '0', '2000-01-01 00:00:01'),
(1270, 1, 108, '0', '2000-01-01 00:00:01'),
(1271, 1, 59, '0', '2000-01-01 00:00:01'),
(1272, 1, 109, '0', '2000-01-01 00:00:01'),
(1273, 1, 110, '0', '2000-01-01 00:00:01'),
(1274, 1, 38, '0', '2000-01-01 00:00:01'),
(1275, 1, 55, '0', '2000-01-01 00:00:01'),
(1276, 1, 111, '0', '2000-01-01 00:00:01'),
(1277, 1, 112, '0', '2000-01-01 00:00:01'),
(1278, 1, 113, '0', '2000-01-01 00:00:01'),
(1279, 1, 14, '0', '2000-01-01 00:00:01'),
(1280, 1, 14, '0', '2000-01-01 00:00:01'),
(1281, 1, 22, '0', '2000-01-01 00:00:01'),
(1282, 1, 23, '0', '2000-01-01 00:00:01'),
(1283, 1, 24, '0', '2000-01-01 00:00:01'),
(1284, 1, 25, '0', '2000-01-01 00:00:01'),
(1285, 1, 26, '0', '2000-01-01 00:00:01'),
(1286, 1, 27, '0', '2000-01-01 00:00:01'),
(1287, 1, 28, '0', '2000-01-01 00:00:01'),
(1288, 1, 29, '0', '2000-01-01 00:00:01'),
(1289, 1, 30, '0', '2000-01-01 00:00:01'),
(1290, 1, 31, '0', '2000-01-01 00:00:01'),
(1291, 1, 32, '0', '2000-01-01 00:00:01'),
(1292, 1, 33, '0', '2000-01-01 00:00:01'),
(1293, 1, 34, '0', '2000-01-01 00:00:01'),
(1294, 1, 35, '0', '2000-01-01 00:00:01'),
(1295, 1, 36, '0', '2000-01-01 00:00:01'),
(1296, 1, 37, '0', '2000-01-01 00:00:01'),
(1297, 1, 38, '0', '2000-01-01 00:00:01'),
(1298, 1, 39, '0', '2000-01-01 00:00:01'),
(1299, 1, 40, '0', '2000-01-01 00:00:01'),
(1300, 1, 41, '0', '2000-01-01 00:00:01'),
(1301, 1, 42, '0', '2000-01-01 00:00:01'),
(1302, 1, 43, '0', '2000-01-01 00:00:01'),
(1303, 1, 44, '0', '2000-01-01 00:00:01'),
(1304, 1, 34, '0', '2000-01-01 00:00:01'),
(1305, 1, 45, '0', '2000-01-01 00:00:01'),
(1306, 1, 46, '0', '2000-01-01 00:00:01'),
(1307, 1, 47, '0', '2000-01-01 00:00:01'),
(1308, 1, 48, '0', '2000-01-01 00:00:01'),
(1309, 1, 49, '0', '2000-01-01 00:00:01'),
(1310, 1, 50, '0', '2000-01-01 00:00:01'),
(1311, 1, 51, '0', '2000-01-01 00:00:01'),
(1312, 1, 52, '0', '2000-01-01 00:00:01'),
(1313, 1, 53, '0', '2000-01-01 00:00:01'),
(1314, 1, 54, '0', '2000-01-01 00:00:01'),
(1315, 1, 55, '0', '2000-01-01 00:00:01'),
(1316, 1, 30, '0', '2000-01-01 00:00:01'),
(1317, 1, 56, '0', '2000-01-01 00:00:01'),
(1318, 1, 57, '0', '2000-01-01 00:00:01'),
(1319, 1, 58, '0', '2000-01-01 00:00:01'),
(1320, 1, 59, '0', '2000-01-01 00:00:01'),
(1321, 1, 60, '0', '2000-01-01 00:00:01'),
(1322, 1, 61, '0', '2000-01-01 00:00:01'),
(1323, 1, 62, '0', '2000-01-01 00:00:01'),
(1324, 1, 63, '0', '2000-01-01 00:00:01'),
(1325, 1, 64, '0', '2000-01-01 00:00:01'),
(1326, 1, 65, '0', '2000-01-01 00:00:01'),
(1327, 1, 26, '0', '2000-01-01 00:00:01'),
(1328, 1, 66, '0', '2000-01-01 00:00:01'),
(1329, 1, 66, '0', '2000-01-01 00:00:01'),
(1330, 1, 5, '0', '2000-01-01 00:00:01'),
(1331, 1, 67, '0', '2000-01-01 00:00:01'),
(1332, 1, 68, '0', '2000-01-01 00:00:01'),
(1333, 1, 39, '0', '2000-01-01 00:00:01'),
(1334, 1, 69, '0', '2000-01-01 00:00:01'),
(1335, 1, 70, '0', '2000-01-01 00:00:01'),
(1336, 1, 28, '0', '2000-01-01 00:00:01'),
(1337, 1, 37, '0', '2000-01-01 00:00:01'),
(1338, 1, 71, '0', '2000-01-01 00:00:01'),
(1339, 1, 72, '0', '2000-01-01 00:00:01'),
(1340, 1, 73, '0', '2000-01-01 00:00:01'),
(1341, 1, 74, '0', '2000-01-01 00:00:01'),
(1342, 1, 75, '0', '2000-01-01 00:00:01'),
(1343, 1, 76, '0', '2000-01-01 00:00:01'),
(1344, 1, 77, '0', '2000-01-01 00:00:01'),
(1345, 1, 78, '0', '2000-01-01 00:00:01'),
(1346, 1, 79, '0', '2000-01-01 00:00:01'),
(1347, 1, 80, '0', '2000-01-01 00:00:01'),
(1348, 1, 81, '0', '2000-01-01 00:00:01'),
(1349, 1, 82, '0', '2000-01-01 00:00:01'),
(1350, 1, 83, '0', '2000-01-01 00:00:01'),
(1351, 1, 84, '0', '2000-01-01 00:00:01'),
(1352, 1, 84, '0', '2000-01-01 00:00:01'),
(1353, 1, 85, '0', '2000-01-01 00:00:01'),
(1354, 1, 86, '0', '2000-01-01 00:00:01'),
(1355, 1, 87, '0', '2000-01-01 00:00:01'),
(1356, 1, 88, '0', '2000-01-01 00:00:01'),
(1357, 1, 2, '0', '2000-01-01 00:00:01'),
(1358, 1, 89, '0', '2000-01-01 00:00:01'),
(1359, 1, 90, '0', '2000-01-01 00:00:01'),
(1360, 1, 91, '0', '2000-01-01 00:00:01'),
(1361, 1, 27, '0', '2000-01-01 00:00:01'),
(1362, 1, 92, '0', '2000-01-01 00:00:01'),
(1363, 1, 93, '0', '2000-01-01 00:00:01'),
(1364, 1, 94, '0', '2000-01-01 00:00:01'),
(1365, 1, 95, '0', '2000-01-01 00:00:01'),
(1366, 1, 48, '0', '2000-01-01 00:00:01'),
(1367, 1, 96, '0', '2000-01-01 00:00:01'),
(1368, 1, 97, '0', '2000-01-01 00:00:01'),
(1369, 1, 84, '0', '2000-01-01 00:00:01'),
(1370, 1, 98, '0', '2000-01-01 00:00:01'),
(1371, 1, 99, '0', '2000-01-01 00:00:01'),
(1372, 1, 52, '0', '2000-01-01 00:00:01'),
(1373, 1, 41, '0', '2000-01-01 00:00:01'),
(1374, 1, 100, '0', '2000-01-01 00:00:01'),
(1375, 1, 101, '0', '2000-01-01 00:00:01'),
(1376, 1, 102, '0', '2000-01-01 00:00:01'),
(1377, 1, 103, '0', '2000-01-01 00:00:01'),
(1378, 1, 104, '0', '2000-01-01 00:00:01'),
(1379, 1, 105, '0', '2000-01-01 00:00:01'),
(1380, 1, 106, '0', '2000-01-01 00:00:01'),
(1381, 1, 107, '0', '2000-01-01 00:00:01'),
(1382, 1, 26, '0', '2000-01-01 00:00:01'),
(1383, 1, 108, '0', '2000-01-01 00:00:01'),
(1384, 1, 59, '0', '2000-01-01 00:00:01'),
(1385, 1, 109, '0', '2000-01-01 00:00:01'),
(1386, 1, 110, '0', '2000-01-01 00:00:01'),
(1387, 1, 38, '0', '2000-01-01 00:00:01'),
(1388, 1, 55, '0', '2000-01-01 00:00:01'),
(1389, 1, 111, '0', '2000-01-01 00:00:01'),
(1390, 1, 112, '0', '2000-01-01 00:00:01'),
(1391, 1, 113, '0', '2000-01-01 00:00:01'),
(1392, 1, 14, '0', '2000-01-01 00:00:01'),
(1393, 1, 14, '0', '2000-01-01 00:00:01'),
(1394, 1, 22, '0', '2000-01-01 00:00:01'),
(1395, 1, 23, '0', '2000-01-01 00:00:01'),
(1396, 1, 24, '0', '2000-01-01 00:00:01'),
(1397, 1, 25, '0', '2000-01-01 00:00:01'),
(1398, 1, 26, '0', '2000-01-01 00:00:01'),
(1399, 1, 27, '0', '2000-01-01 00:00:01'),
(1400, 1, 28, '0', '2000-01-01 00:00:01'),
(1401, 1, 29, '0', '2000-01-01 00:00:01'),
(1402, 1, 30, '0', '2000-01-01 00:00:01'),
(1403, 1, 31, '0', '2000-01-01 00:00:01'),
(1404, 1, 32, '0', '2000-01-01 00:00:01'),
(1405, 1, 33, '0', '2000-01-01 00:00:01'),
(1406, 1, 34, '0', '2000-01-01 00:00:01'),
(1407, 1, 35, '0', '2000-01-01 00:00:01'),
(1408, 1, 36, '0', '2000-01-01 00:00:01'),
(1409, 1, 37, '0', '2000-01-01 00:00:01'),
(1410, 1, 38, '0', '2000-01-01 00:00:01'),
(1411, 1, 39, '0', '2000-01-01 00:00:01'),
(1412, 1, 40, '0', '2000-01-01 00:00:01'),
(1413, 1, 41, '0', '2000-01-01 00:00:01'),
(1414, 1, 42, '0', '2000-01-01 00:00:01'),
(1415, 1, 43, '0', '2000-01-01 00:00:01'),
(1416, 1, 44, '0', '2000-01-01 00:00:01'),
(1417, 1, 34, '0', '2000-01-01 00:00:01'),
(1418, 1, 45, '0', '2000-01-01 00:00:01'),
(1419, 1, 46, '0', '2000-01-01 00:00:01'),
(1420, 1, 47, '0', '2000-01-01 00:00:01'),
(1421, 1, 48, '0', '2000-01-01 00:00:01'),
(1422, 1, 49, '0', '2000-01-01 00:00:01'),
(1423, 1, 50, '0', '2000-01-01 00:00:01'),
(1424, 1, 51, '0', '2000-01-01 00:00:01'),
(1425, 1, 52, '0', '2000-01-01 00:00:01'),
(1426, 1, 53, '0', '2000-01-01 00:00:01'),
(1427, 1, 54, '0', '2000-01-01 00:00:01'),
(1428, 1, 55, '0', '2000-01-01 00:00:01'),
(1429, 1, 30, '0', '2000-01-01 00:00:01'),
(1430, 1, 56, '0', '2000-01-01 00:00:01'),
(1431, 1, 57, '0', '2000-01-01 00:00:01'),
(1432, 1, 58, '0', '2000-01-01 00:00:01'),
(1433, 1, 59, '0', '2000-01-01 00:00:01'),
(1434, 1, 60, '0', '2000-01-01 00:00:01'),
(1435, 1, 61, '0', '2000-01-01 00:00:01'),
(1436, 1, 62, '0', '2000-01-01 00:00:01'),
(1437, 1, 63, '0', '2000-01-01 00:00:01'),
(1438, 1, 64, '0', '2000-01-01 00:00:01'),
(1439, 1, 14, '0', '2000-01-01 00:00:01'),
(1440, 1, 65, '0', '2000-01-01 00:00:01'),
(1441, 1, 14, '0', '2000-01-01 00:00:01'),
(1442, 1, 26, '0', '2000-01-01 00:00:01'),
(1443, 1, 22, '0', '2000-01-01 00:00:01'),
(1444, 1, 66, '0', '2000-01-01 00:00:01'),
(1445, 1, 23, '0', '2000-01-01 00:00:01'),
(1446, 1, 66, '0', '2000-01-01 00:00:01'),
(1447, 1, 24, '0', '2000-01-01 00:00:01'),
(1448, 1, 5, '0', '2000-01-01 00:00:01'),
(1449, 1, 25, '0', '2000-01-01 00:00:01'),
(1450, 1, 67, '0', '2000-01-01 00:00:01'),
(1451, 1, 26, '0', '2000-01-01 00:00:01'),
(1452, 1, 68, '0', '2000-01-01 00:00:01'),
(1453, 1, 27, '0', '2000-01-01 00:00:01'),
(1454, 1, 39, '0', '2000-01-01 00:00:01'),
(1455, 1, 28, '0', '2000-01-01 00:00:01'),
(1456, 1, 69, '0', '2000-01-01 00:00:01'),
(1457, 1, 29, '0', '2000-01-01 00:00:01'),
(1458, 1, 70, '0', '2000-01-01 00:00:01'),
(1459, 1, 30, '0', '2000-01-01 00:00:01'),
(1460, 1, 28, '0', '2000-01-01 00:00:01'),
(1461, 1, 31, '0', '2000-01-01 00:00:01'),
(1462, 1, 37, '0', '2000-01-01 00:00:01'),
(1463, 1, 32, '0', '2000-01-01 00:00:01'),
(1464, 1, 71, '0', '2000-01-01 00:00:01'),
(1465, 1, 33, '0', '2000-01-01 00:00:01'),
(1466, 1, 72, '0', '2000-01-01 00:00:01'),
(1467, 1, 34, '0', '2000-01-01 00:00:01'),
(1468, 1, 73, '0', '2000-01-01 00:00:01'),
(1469, 1, 35, '0', '2000-01-01 00:00:01'),
(1470, 1, 74, '0', '2000-01-01 00:00:01'),
(1471, 1, 36, '0', '2000-01-01 00:00:01'),
(1472, 1, 75, '0', '2000-01-01 00:00:01'),
(1473, 1, 37, '0', '2000-01-01 00:00:01'),
(1474, 1, 76, '0', '2000-01-01 00:00:01'),
(1475, 1, 38, '0', '2000-01-01 00:00:01'),
(1476, 1, 77, '0', '2000-01-01 00:00:01'),
(1477, 1, 39, '0', '2000-01-01 00:00:01'),
(1478, 1, 78, '0', '2000-01-01 00:00:01'),
(1479, 1, 40, '0', '2000-01-01 00:00:01'),
(1480, 1, 79, '0', '2000-01-01 00:00:01'),
(1481, 1, 41, '0', '2000-01-01 00:00:01'),
(1482, 1, 80, '0', '2000-01-01 00:00:01'),
(1483, 1, 42, '0', '2000-01-01 00:00:01'),
(1484, 1, 81, '0', '2000-01-01 00:00:01'),
(1485, 1, 43, '0', '2000-01-01 00:00:01'),
(1486, 1, 82, '0', '2000-01-01 00:00:01'),
(1487, 1, 44, '0', '2000-01-01 00:00:01'),
(1488, 1, 83, '0', '2000-01-01 00:00:01'),
(1489, 1, 34, '0', '2000-01-01 00:00:01'),
(1490, 1, 84, '0', '2000-01-01 00:00:01'),
(1491, 1, 45, '0', '2000-01-01 00:00:01'),
(1492, 1, 84, '0', '2000-01-01 00:00:01'),
(1493, 1, 46, '0', '2000-01-01 00:00:01'),
(1494, 1, 85, '0', '2000-01-01 00:00:01'),
(1495, 1, 47, '0', '2000-01-01 00:00:01'),
(1496, 1, 86, '0', '2000-01-01 00:00:01'),
(1497, 1, 48, '0', '2000-01-01 00:00:01'),
(1498, 1, 87, '0', '2000-01-01 00:00:01'),
(1499, 1, 49, '0', '2000-01-01 00:00:01'),
(1500, 1, 88, '0', '2000-01-01 00:00:01'),
(1501, 1, 50, '0', '2000-01-01 00:00:01'),
(1502, 1, 2, '0', '2000-01-01 00:00:01'),
(1503, 1, 51, '0', '2000-01-01 00:00:01'),
(1504, 1, 89, '0', '2000-01-01 00:00:01'),
(1505, 1, 52, '0', '2000-01-01 00:00:01'),
(1506, 1, 90, '0', '2000-01-01 00:00:01'),
(1507, 1, 53, '0', '2000-01-01 00:00:01'),
(1508, 1, 91, '0', '2000-01-01 00:00:01'),
(1509, 1, 54, '0', '2000-01-01 00:00:01'),
(1510, 1, 27, '0', '2000-01-01 00:00:01'),
(1511, 1, 55, '0', '2000-01-01 00:00:01'),
(1512, 1, 92, '0', '2000-01-01 00:00:01'),
(1513, 1, 30, '0', '2000-01-01 00:00:01'),
(1514, 1, 93, '0', '2000-01-01 00:00:01'),
(1515, 1, 56, '0', '2000-01-01 00:00:01'),
(1516, 1, 94, '0', '2000-01-01 00:00:01'),
(1517, 1, 57, '0', '2000-01-01 00:00:01'),
(1518, 1, 95, '0', '2000-01-01 00:00:01'),
(1519, 1, 58, '0', '2000-01-01 00:00:01'),
(1520, 1, 48, '0', '2000-01-01 00:00:01'),
(1521, 1, 59, '0', '2000-01-01 00:00:01'),
(1522, 1, 96, '0', '2000-01-01 00:00:01'),
(1523, 1, 60, '0', '2000-01-01 00:00:01'),
(1524, 1, 97, '0', '2000-01-01 00:00:01'),
(1525, 1, 61, '0', '2000-01-01 00:00:01'),
(1526, 1, 84, '0', '2000-01-01 00:00:01'),
(1527, 1, 62, '0', '2000-01-01 00:00:01'),
(1528, 1, 98, '0', '2000-01-01 00:00:01'),
(1529, 1, 63, '0', '2000-01-01 00:00:01'),
(1530, 1, 99, '0', '2000-01-01 00:00:01'),
(1531, 1, 64, '0', '2000-01-01 00:00:01'),
(1532, 1, 52, '0', '2000-01-01 00:00:01'),
(1533, 1, 65, '0', '2000-01-01 00:00:01'),
(1534, 1, 41, '0', '2000-01-01 00:00:01'),
(1535, 1, 26, '0', '2000-01-01 00:00:01'),
(1536, 1, 100, '0', '2000-01-01 00:00:01'),
(1537, 1, 66, '0', '2000-01-01 00:00:01'),
(1538, 1, 101, '0', '2000-01-01 00:00:01'),
(1539, 1, 66, '0', '2000-01-01 00:00:01'),
(1540, 1, 102, '0', '2000-01-01 00:00:01'),
(1541, 1, 5, '0', '2000-01-01 00:00:01'),
(1542, 1, 103, '0', '2000-01-01 00:00:01'),
(1543, 1, 67, '0', '2000-01-01 00:00:01'),
(1544, 1, 104, '0', '2000-01-01 00:00:01'),
(1545, 1, 68, '0', '2000-01-01 00:00:01'),
(1546, 1, 105, '0', '2000-01-01 00:00:01'),
(1547, 1, 39, '0', '2000-01-01 00:00:01'),
(1548, 1, 106, '0', '2000-01-01 00:00:01'),
(1549, 1, 69, '0', '2000-01-01 00:00:01'),
(1550, 1, 107, '0', '2000-01-01 00:00:01'),
(1551, 1, 70, '0', '2000-01-01 00:00:01'),
(1552, 1, 26, '0', '2000-01-01 00:00:01'),
(1553, 1, 28, '0', '2000-01-01 00:00:01'),
(1554, 1, 108, '0', '2000-01-01 00:00:01'),
(1555, 1, 37, '0', '2000-01-01 00:00:01'),
(1556, 1, 59, '0', '2000-01-01 00:00:01'),
(1557, 1, 71, '0', '2000-01-01 00:00:01'),
(1558, 1, 109, '0', '2000-01-01 00:00:01'),
(1559, 1, 72, '0', '2000-01-01 00:00:01'),
(1560, 1, 110, '0', '2000-01-01 00:00:01'),
(1561, 1, 73, '0', '2000-01-01 00:00:01'),
(1562, 1, 38, '0', '2000-01-01 00:00:01'),
(1563, 1, 74, '0', '2000-01-01 00:00:01'),
(1564, 1, 55, '0', '2000-01-01 00:00:01'),
(1565, 1, 75, '0', '2000-01-01 00:00:01'),
(1566, 1, 111, '0', '2000-01-01 00:00:01'),
(1567, 1, 76, '0', '2000-01-01 00:00:01'),
(1568, 1, 112, '0', '2000-01-01 00:00:01'),
(1569, 1, 77, '0', '2000-01-01 00:00:01'),
(1570, 1, 113, '0', '2000-01-01 00:00:01'),
(1571, 1, 78, '0', '2000-01-01 00:00:01'),
(1572, 1, 79, '0', '2000-01-01 00:00:01'),
(1573, 1, 80, '0', '2000-01-01 00:00:01'),
(1574, 1, 81, '0', '2000-01-01 00:00:01'),
(1575, 1, 82, '0', '2000-01-01 00:00:01'),
(1576, 1, 83, '0', '2000-01-01 00:00:01'),
(1577, 1, 84, '0', '2000-01-01 00:00:01'),
(1578, 1, 84, '0', '2000-01-01 00:00:01'),
(1579, 1, 85, '0', '2000-01-01 00:00:01'),
(1580, 1, 86, '0', '2000-01-01 00:00:01'),
(1581, 1, 87, '0', '2000-01-01 00:00:01'),
(1582, 1, 88, '0', '2000-01-01 00:00:01'),
(1583, 1, 2, '0', '2000-01-01 00:00:01'),
(1584, 1, 89, '0', '2000-01-01 00:00:01'),
(1585, 1, 90, '0', '2000-01-01 00:00:01'),
(1586, 1, 91, '0', '2000-01-01 00:00:01'),
(1587, 1, 27, '0', '2000-01-01 00:00:01'),
(1588, 1, 92, '0', '2000-01-01 00:00:01'),
(1589, 1, 93, '0', '2000-01-01 00:00:01'),
(1590, 1, 94, '0', '2000-01-01 00:00:01'),
(1591, 1, 95, '0', '2000-01-01 00:00:01'),
(1592, 1, 48, '0', '2000-01-01 00:00:01'),
(1593, 1, 96, '0', '2000-01-01 00:00:01'),
(1594, 1, 97, '0', '2000-01-01 00:00:01'),
(1595, 1, 84, '0', '2000-01-01 00:00:01'),
(1596, 1, 98, '0', '2000-01-01 00:00:01'),
(1597, 1, 99, '0', '2000-01-01 00:00:01'),
(1598, 1, 52, '0', '2000-01-01 00:00:01'),
(1599, 1, 41, '0', '2000-01-01 00:00:01'),
(1600, 1, 100, '0', '2000-01-01 00:00:01'),
(1601, 1, 101, '0', '2000-01-01 00:00:01'),
(1602, 1, 102, '0', '2000-01-01 00:00:01'),
(1603, 1, 103, '0', '2000-01-01 00:00:01'),
(1604, 1, 104, '0', '2000-01-01 00:00:01'),
(1605, 1, 105, '0', '2000-01-01 00:00:01'),
(1606, 1, 106, '0', '2000-01-01 00:00:01'),
(1607, 1, 107, '0', '2000-01-01 00:00:01'),
(1608, 1, 26, '0', '2000-01-01 00:00:01'),
(1609, 1, 108, '0', '2000-01-01 00:00:01'),
(1610, 1, 59, '0', '2000-01-01 00:00:01'),
(1611, 1, 109, '0', '2000-01-01 00:00:01'),
(1612, 1, 110, '0', '2000-01-01 00:00:01'),
(1613, 1, 38, '0', '2000-01-01 00:00:01'),
(1614, 1, 55, '0', '2000-01-01 00:00:01'),
(1615, 1, 111, '0', '2000-01-01 00:00:01'),
(1616, 1, 112, '0', '2000-01-01 00:00:01'),
(1617, 1, 113, '0', '2000-01-01 00:00:01'),
(1618, 1, 14, '0', '2000-01-01 00:00:01'),
(1619, 1, 14, '0', '2000-01-01 00:00:01'),
(1620, 1, 22, '0', '2000-01-01 00:00:01'),
(1621, 1, 23, '0', '2000-01-01 00:00:01'),
(1622, 1, 24, '0', '2000-01-01 00:00:01'),
(1623, 1, 25, '0', '2000-01-01 00:00:01'),
(1624, 1, 26, '0', '2000-01-01 00:00:01'),
(1625, 1, 27, '0', '2000-01-01 00:00:01'),
(1626, 1, 28, '0', '2000-01-01 00:00:01'),
(1627, 1, 29, '0', '2000-01-01 00:00:01'),
(1628, 1, 30, '0', '2000-01-01 00:00:01'),
(1629, 1, 31, '0', '2000-01-01 00:00:01'),
(1630, 1, 32, '0', '2000-01-01 00:00:01'),
(1631, 1, 33, '0', '2000-01-01 00:00:01'),
(1632, 1, 34, '0', '2000-01-01 00:00:01'),
(1633, 1, 35, '0', '2000-01-01 00:00:01'),
(1634, 1, 36, '0', '2000-01-01 00:00:01'),
(1635, 1, 37, '0', '2000-01-01 00:00:01'),
(1636, 1, 38, '0', '2000-01-01 00:00:01'),
(1637, 1, 39, '0', '2000-01-01 00:00:01'),
(1638, 1, 40, '0', '2000-01-01 00:00:01'),
(1639, 1, 41, '0', '2000-01-01 00:00:01'),
(1640, 1, 42, '0', '2000-01-01 00:00:01'),
(1641, 1, 43, '0', '2000-01-01 00:00:01'),
(1642, 1, 44, '0', '2000-01-01 00:00:01'),
(1643, 1, 34, '0', '2000-01-01 00:00:01'),
(1644, 1, 45, '0', '2000-01-01 00:00:01'),
(1645, 1, 46, '0', '2000-01-01 00:00:01'),
(1646, 1, 47, '0', '2000-01-01 00:00:01'),
(1647, 1, 48, '0', '2000-01-01 00:00:01'),
(1648, 1, 49, '0', '2000-01-01 00:00:01'),
(1649, 1, 50, '0', '2000-01-01 00:00:01'),
(1650, 1, 51, '0', '2000-01-01 00:00:01'),
(1651, 1, 52, '0', '2000-01-01 00:00:01'),
(1652, 1, 53, '0', '2000-01-01 00:00:01'),
(1653, 1, 54, '0', '2000-01-01 00:00:01'),
(1654, 1, 55, '0', '2000-01-01 00:00:01'),
(1655, 1, 30, '0', '2000-01-01 00:00:01'),
(1656, 1, 56, '0', '2000-01-01 00:00:01'),
(1657, 1, 57, '0', '2000-01-01 00:00:01'),
(1658, 1, 58, '0', '2000-01-01 00:00:01'),
(1659, 1, 59, '0', '2000-01-01 00:00:01'),
(1660, 1, 60, '0', '2000-01-01 00:00:01'),
(1661, 1, 61, '0', '2000-01-01 00:00:01'),
(1662, 1, 62, '0', '2000-01-01 00:00:01'),
(1663, 1, 63, '0', '2000-01-01 00:00:01'),
(1664, 1, 64, '0', '2000-01-01 00:00:01'),
(1665, 1, 65, '0', '2000-01-01 00:00:01'),
(1666, 1, 26, '0', '2000-01-01 00:00:01'),
(1667, 1, 66, '0', '2000-01-01 00:00:01'),
(1668, 1, 66, '0', '2000-01-01 00:00:01'),
(1669, 1, 5, '0', '2000-01-01 00:00:01'),
(1670, 1, 67, '0', '2000-01-01 00:00:01'),
(1671, 1, 68, '0', '2000-01-01 00:00:01'),
(1672, 1, 39, '0', '2000-01-01 00:00:01'),
(1673, 1, 69, '0', '2000-01-01 00:00:01'),
(1674, 1, 70, '0', '2000-01-01 00:00:01'),
(1675, 1, 28, '0', '2000-01-01 00:00:01'),
(1676, 1, 37, '0', '2000-01-01 00:00:01'),
(1677, 1, 71, '0', '2000-01-01 00:00:01'),
(1678, 1, 72, '0', '2000-01-01 00:00:01'),
(1679, 1, 73, '0', '2000-01-01 00:00:01'),
(1680, 1, 74, '0', '2000-01-01 00:00:01'),
(1681, 1, 75, '0', '2000-01-01 00:00:01'),
(1682, 1, 76, '0', '2000-01-01 00:00:01'),
(1683, 1, 77, '0', '2000-01-01 00:00:01'),
(1684, 1, 78, '0', '2000-01-01 00:00:01'),
(1685, 1, 79, '0', '2000-01-01 00:00:01'),
(1686, 1, 80, '0', '2000-01-01 00:00:01'),
(1687, 1, 81, '0', '2000-01-01 00:00:01'),
(1688, 1, 82, '0', '2000-01-01 00:00:01'),
(1689, 1, 83, '0', '2000-01-01 00:00:01'),
(1690, 1, 84, '0', '2000-01-01 00:00:01'),
(1691, 1, 84, '0', '2000-01-01 00:00:01'),
(1692, 1, 85, '0', '2000-01-01 00:00:01'),
(1693, 1, 86, '0', '2000-01-01 00:00:01'),
(1694, 1, 87, '0', '2000-01-01 00:00:01'),
(1695, 1, 88, '0', '2000-01-01 00:00:01'),
(1696, 1, 2, '0', '2000-01-01 00:00:01'),
(1697, 1, 89, '0', '2000-01-01 00:00:01'),
(1698, 1, 90, '0', '2000-01-01 00:00:01'),
(1699, 1, 91, '0', '2000-01-01 00:00:01'),
(1700, 1, 27, '0', '2000-01-01 00:00:01'),
(1701, 1, 92, '0', '2000-01-01 00:00:01'),
(1702, 1, 93, '0', '2000-01-01 00:00:01'),
(1703, 1, 94, '0', '2000-01-01 00:00:01'),
(1704, 1, 95, '0', '2000-01-01 00:00:01'),
(1705, 1, 48, '0', '2000-01-01 00:00:01'),
(1706, 1, 96, '0', '2000-01-01 00:00:01'),
(1707, 1, 97, '0', '2000-01-01 00:00:01'),
(1708, 1, 84, '0', '2000-01-01 00:00:01'),
(1709, 1, 98, '0', '2000-01-01 00:00:01'),
(1710, 1, 99, '0', '2000-01-01 00:00:01'),
(1711, 1, 52, '0', '2000-01-01 00:00:01'),
(1712, 1, 41, '0', '2000-01-01 00:00:01'),
(1713, 1, 100, '0', '2000-01-01 00:00:01'),
(1714, 1, 101, '0', '2000-01-01 00:00:01'),
(1715, 1, 102, '0', '2000-01-01 00:00:01'),
(1716, 1, 103, '0', '2000-01-01 00:00:01'),
(1717, 1, 104, '0', '2000-01-01 00:00:01'),
(1718, 1, 105, '0', '2000-01-01 00:00:01'),
(1719, 1, 106, '0', '2000-01-01 00:00:01'),
(1720, 1, 107, '0', '2000-01-01 00:00:01'),
(1721, 1, 26, '0', '2000-01-01 00:00:01'),
(1722, 1, 108, '0', '2000-01-01 00:00:01'),
(1723, 1, 59, '0', '2000-01-01 00:00:01'),
(1724, 1, 109, '0', '2000-01-01 00:00:01'),
(1725, 1, 110, '0', '2000-01-01 00:00:01'),
(1726, 1, 38, '0', '2000-01-01 00:00:01'),
(1727, 1, 55, '0', '2000-01-01 00:00:01'),
(1728, 1, 111, '0', '2000-01-01 00:00:01'),
(1729, 1, 112, '0', '2000-01-01 00:00:01'),
(1730, 1, 113, '0', '2000-01-01 00:00:01'),
(1731, 1, 14, '0', '2000-01-01 00:00:01'),
(1732, 1, 14, '0', '2000-01-01 00:00:01'),
(1733, 1, 22, '0', '2000-01-01 00:00:01'),
(1734, 1, 23, '0', '2000-01-01 00:00:01'),
(1735, 1, 24, '0', '2000-01-01 00:00:01'),
(1736, 1, 25, '0', '2000-01-01 00:00:01'),
(1737, 1, 26, '0', '2000-01-01 00:00:01'),
(1738, 1, 27, '0', '2000-01-01 00:00:01'),
(1739, 1, 28, '0', '2000-01-01 00:00:01'),
(1740, 1, 29, '0', '2000-01-01 00:00:01'),
(1741, 1, 30, '0', '2000-01-01 00:00:01'),
(1742, 1, 31, '0', '2000-01-01 00:00:01'),
(1743, 1, 32, '0', '2000-01-01 00:00:01'),
(1744, 1, 33, '0', '2000-01-01 00:00:01'),
(1745, 1, 34, '0', '2000-01-01 00:00:01'),
(1746, 1, 35, '0', '2000-01-01 00:00:01'),
(1747, 1, 36, '0', '2000-01-01 00:00:01'),
(1748, 1, 37, '0', '2000-01-01 00:00:01'),
(1749, 1, 38, '0', '2000-01-01 00:00:01'),
(1750, 1, 39, '0', '2000-01-01 00:00:01'),
(1751, 1, 40, '0', '2000-01-01 00:00:01'),
(1752, 1, 41, '0', '2000-01-01 00:00:01'),
(1753, 1, 42, '0', '2000-01-01 00:00:01'),
(1754, 1, 43, '0', '2000-01-01 00:00:01'),
(1755, 1, 44, '0', '2000-01-01 00:00:01'),
(1756, 1, 34, '0', '2000-01-01 00:00:01'),
(1757, 1, 45, '0', '2000-01-01 00:00:01'),
(1758, 1, 46, '0', '2000-01-01 00:00:01'),
(1759, 1, 47, '0', '2000-01-01 00:00:01'),
(1760, 1, 48, '0', '2000-01-01 00:00:01'),
(1761, 1, 49, '0', '2000-01-01 00:00:01'),
(1762, 1, 50, '0', '2000-01-01 00:00:01'),
(1763, 1, 51, '0', '2000-01-01 00:00:01'),
(1764, 1, 52, '0', '2000-01-01 00:00:01'),
(1765, 1, 53, '0', '2000-01-01 00:00:01'),
(1766, 1, 54, '0', '2000-01-01 00:00:01'),
(1767, 1, 55, '0', '2000-01-01 00:00:01'),
(1768, 1, 30, '0', '2000-01-01 00:00:01'),
(1769, 1, 56, '0', '2000-01-01 00:00:01'),
(1770, 1, 57, '0', '2000-01-01 00:00:01'),
(1771, 1, 58, '0', '2000-01-01 00:00:01'),
(1772, 1, 59, '0', '2000-01-01 00:00:01'),
(1773, 1, 60, '0', '2000-01-01 00:00:01'),
(1774, 1, 61, '0', '2000-01-01 00:00:01'),
(1775, 1, 62, '0', '2000-01-01 00:00:01'),
(1776, 1, 63, '0', '2000-01-01 00:00:01'),
(1777, 1, 64, '0', '2000-01-01 00:00:01'),
(1778, 1, 65, '0', '2000-01-01 00:00:01'),
(1779, 1, 26, '0', '2000-01-01 00:00:01'),
(1780, 1, 66, '0', '2000-01-01 00:00:01'),
(1781, 1, 66, '0', '2000-01-01 00:00:01'),
(1782, 1, 5, '0', '2000-01-01 00:00:01'),
(1783, 1, 67, '0', '2000-01-01 00:00:01'),
(1784, 1, 68, '0', '2000-01-01 00:00:01'),
(1785, 1, 39, '0', '2000-01-01 00:00:01'),
(1786, 1, 69, '0', '2000-01-01 00:00:01'),
(1787, 1, 70, '0', '2000-01-01 00:00:01'),
(1788, 1, 28, '0', '2000-01-01 00:00:01'),
(1789, 1, 37, '0', '2000-01-01 00:00:01'),
(1790, 1, 71, '0', '2000-01-01 00:00:01'),
(1791, 1, 72, '0', '2000-01-01 00:00:01'),
(1792, 1, 73, '0', '2000-01-01 00:00:01'),
(1793, 1, 74, '0', '2000-01-01 00:00:01'),
(1794, 1, 75, '0', '2000-01-01 00:00:01'),
(1795, 1, 76, '0', '2000-01-01 00:00:01'),
(1796, 1, 77, '0', '2000-01-01 00:00:01'),
(1797, 1, 78, '0', '2000-01-01 00:00:01'),
(1798, 1, 79, '0', '2000-01-01 00:00:01'),
(1799, 1, 80, '0', '2000-01-01 00:00:01'),
(1800, 1, 81, '0', '2000-01-01 00:00:01'),
(1801, 1, 82, '0', '2000-01-01 00:00:01'),
(1802, 1, 83, '0', '2000-01-01 00:00:01'),
(1803, 1, 84, '0', '2000-01-01 00:00:01'),
(1804, 1, 84, '0', '2000-01-01 00:00:01'),
(1805, 1, 85, '0', '2000-01-01 00:00:01'),
(1806, 1, 86, '0', '2000-01-01 00:00:01'),
(1807, 1, 87, '0', '2000-01-01 00:00:01'),
(1808, 1, 88, '0', '2000-01-01 00:00:01'),
(1809, 1, 2, '0', '2000-01-01 00:00:01'),
(1810, 1, 89, '0', '2000-01-01 00:00:01'),
(1811, 1, 90, '0', '2000-01-01 00:00:01'),
(1812, 1, 91, '0', '2000-01-01 00:00:01'),
(1813, 1, 27, '0', '2000-01-01 00:00:01'),
(1814, 1, 92, '0', '2000-01-01 00:00:01'),
(1815, 1, 93, '0', '2000-01-01 00:00:01'),
(1816, 1, 94, '0', '2000-01-01 00:00:01'),
(1817, 1, 95, '0', '2000-01-01 00:00:01'),
(1818, 1, 48, '0', '2000-01-01 00:00:01'),
(1819, 1, 96, '0', '2000-01-01 00:00:01'),
(1820, 1, 97, '0', '2000-01-01 00:00:01'),
(1821, 1, 84, '0', '2000-01-01 00:00:01'),
(1822, 1, 98, '0', '2000-01-01 00:00:01'),
(1823, 1, 99, '0', '2000-01-01 00:00:01'),
(1824, 1, 52, '0', '2000-01-01 00:00:01'),
(1825, 1, 41, '0', '2000-01-01 00:00:01'),
(1826, 1, 100, '0', '2000-01-01 00:00:01'),
(1827, 1, 101, '0', '2000-01-01 00:00:01'),
(1828, 1, 102, '0', '2000-01-01 00:00:01'),
(1829, 1, 103, '0', '2000-01-01 00:00:01'),
(1830, 1, 104, '0', '2000-01-01 00:00:01'),
(1831, 1, 105, '0', '2000-01-01 00:00:01'),
(1832, 1, 106, '0', '2000-01-01 00:00:01'),
(1833, 1, 107, '0', '2000-01-01 00:00:01'),
(1834, 1, 26, '0', '2000-01-01 00:00:01'),
(1835, 1, 108, '0', '2000-01-01 00:00:01'),
(1836, 1, 59, '0', '2000-01-01 00:00:01'),
(1837, 1, 109, '0', '2000-01-01 00:00:01'),
(1838, 1, 110, '0', '2000-01-01 00:00:01'),
(1839, 1, 38, '0', '2000-01-01 00:00:01'),
(1840, 1, 55, '0', '2000-01-01 00:00:01'),
(1841, 1, 111, '0', '2000-01-01 00:00:01'),
(1842, 1, 112, '0', '2000-01-01 00:00:01'),
(1843, 1, 113, '0', '2000-01-01 00:00:01'),
(1844, 1, 14, '0', '2000-01-01 00:00:01'),
(1845, 1, 14, '0', '2000-01-01 00:00:01'),
(1846, 1, 22, '0', '2000-01-01 00:00:01'),
(1847, 1, 23, '0', '2000-01-01 00:00:01'),
(1848, 1, 24, '0', '2000-01-01 00:00:01'),
(1849, 1, 25, '0', '2000-01-01 00:00:01'),
(1850, 1, 26, '0', '2000-01-01 00:00:01'),
(1851, 1, 27, '0', '2000-01-01 00:00:01'),
(1852, 1, 28, '0', '2000-01-01 00:00:01'),
(1853, 1, 29, '0', '2000-01-01 00:00:01'),
(1854, 1, 30, '0', '2000-01-01 00:00:01'),
(1855, 1, 31, '0', '2000-01-01 00:00:01'),
(1856, 1, 32, '0', '2000-01-01 00:00:01'),
(1857, 1, 33, '0', '2000-01-01 00:00:01'),
(1858, 1, 34, '0', '2000-01-01 00:00:01'),
(1859, 1, 35, '0', '2000-01-01 00:00:01'),
(1860, 1, 36, '0', '2000-01-01 00:00:01'),
(1861, 1, 37, '0', '2000-01-01 00:00:01'),
(1862, 1, 38, '0', '2000-01-01 00:00:01'),
(1863, 1, 39, '0', '2000-01-01 00:00:01'),
(1864, 1, 40, '0', '2000-01-01 00:00:01'),
(1865, 1, 41, '0', '2000-01-01 00:00:01'),
(1866, 1, 42, '0', '2000-01-01 00:00:01'),
(1867, 1, 43, '0', '2000-01-01 00:00:01'),
(1868, 1, 44, '0', '2000-01-01 00:00:01'),
(1869, 1, 34, '0', '2000-01-01 00:00:01'),
(1870, 1, 45, '0', '2000-01-01 00:00:01'),
(1871, 1, 46, '0', '2000-01-01 00:00:01'),
(1872, 1, 47, '0', '2000-01-01 00:00:01'),
(1873, 1, 48, '0', '2000-01-01 00:00:01'),
(1874, 1, 49, '0', '2000-01-01 00:00:01'),
(1875, 1, 50, '0', '2000-01-01 00:00:01'),
(1876, 1, 51, '0', '2000-01-01 00:00:01'),
(1877, 1, 52, '0', '2000-01-01 00:00:01'),
(1878, 1, 53, '0', '2000-01-01 00:00:01'),
(1879, 1, 54, '0', '2000-01-01 00:00:01'),
(1880, 1, 55, '0', '2000-01-01 00:00:01'),
(1881, 1, 30, '0', '2000-01-01 00:00:01'),
(1882, 1, 56, '0', '2000-01-01 00:00:01'),
(1883, 1, 57, '0', '2000-01-01 00:00:01'),
(1884, 1, 58, '0', '2000-01-01 00:00:01'),
(1885, 1, 59, '0', '2000-01-01 00:00:01'),
(1886, 1, 60, '0', '2000-01-01 00:00:01'),
(1887, 1, 61, '0', '2000-01-01 00:00:01'),
(1888, 1, 62, '0', '2000-01-01 00:00:01'),
(1889, 1, 63, '0', '2000-01-01 00:00:01'),
(1890, 1, 64, '0', '2000-01-01 00:00:01'),
(1891, 1, 65, '0', '2000-01-01 00:00:01'),
(1892, 1, 26, '0', '2000-01-01 00:00:01'),
(1893, 1, 66, '0', '2000-01-01 00:00:01'),
(1894, 1, 66, '0', '2000-01-01 00:00:01'),
(1895, 1, 5, '0', '2000-01-01 00:00:01'),
(1896, 1, 67, '0', '2000-01-01 00:00:01'),
(1897, 1, 68, '0', '2000-01-01 00:00:01'),
(1898, 1, 39, '0', '2000-01-01 00:00:01'),
(1899, 1, 69, '0', '2000-01-01 00:00:01'),
(1900, 1, 70, '0', '2000-01-01 00:00:01'),
(1901, 1, 28, '0', '2000-01-01 00:00:01'),
(1902, 1, 37, '0', '2000-01-01 00:00:01'),
(1903, 1, 71, '0', '2000-01-01 00:00:01'),
(1904, 1, 72, '0', '2000-01-01 00:00:01'),
(1905, 1, 73, '0', '2000-01-01 00:00:01'),
(1906, 1, 74, '0', '2000-01-01 00:00:01'),
(1907, 1, 75, '0', '2000-01-01 00:00:01'),
(1908, 1, 76, '0', '2000-01-01 00:00:01'),
(1909, 1, 77, '0', '2000-01-01 00:00:01'),
(1910, 1, 78, '0', '2000-01-01 00:00:01'),
(1911, 1, 79, '0', '2000-01-01 00:00:01'),
(1912, 1, 80, '0', '2000-01-01 00:00:01'),
(1913, 1, 81, '0', '2000-01-01 00:00:01'),
(1914, 1, 82, '0', '2000-01-01 00:00:01'),
(1915, 1, 83, '0', '2000-01-01 00:00:01'),
(1916, 1, 84, '0', '2000-01-01 00:00:01'),
(1917, 1, 84, '0', '2000-01-01 00:00:01'),
(1918, 1, 85, '0', '2000-01-01 00:00:01'),
(1919, 1, 86, '0', '2000-01-01 00:00:01'),
(1920, 1, 87, '0', '2000-01-01 00:00:01'),
(1921, 1, 88, '0', '2000-01-01 00:00:01'),
(1922, 1, 2, '0', '2000-01-01 00:00:01'),
(1923, 1, 89, '0', '2000-01-01 00:00:01'),
(1924, 1, 90, '0', '2000-01-01 00:00:01'),
(1925, 1, 91, '0', '2000-01-01 00:00:01'),
(1926, 1, 27, '0', '2000-01-01 00:00:01'),
(1927, 1, 92, '0', '2000-01-01 00:00:01'),
(1928, 1, 93, '0', '2000-01-01 00:00:01'),
(1929, 1, 94, '0', '2000-01-01 00:00:01'),
(1930, 1, 95, '0', '2000-01-01 00:00:01'),
(1931, 1, 48, '0', '2000-01-01 00:00:01'),
(1932, 1, 96, '0', '2000-01-01 00:00:01'),
(1933, 1, 97, '0', '2000-01-01 00:00:01'),
(1934, 1, 84, '0', '2000-01-01 00:00:01'),
(1935, 1, 98, '0', '2000-01-01 00:00:01'),
(1936, 1, 99, '0', '2000-01-01 00:00:01'),
(1937, 1, 52, '0', '2000-01-01 00:00:01'),
(1938, 1, 41, '0', '2000-01-01 00:00:01'),
(1939, 1, 100, '0', '2000-01-01 00:00:01'),
(1940, 1, 101, '0', '2000-01-01 00:00:01'),
(1941, 1, 102, '0', '2000-01-01 00:00:01'),
(1942, 1, 103, '0', '2000-01-01 00:00:01'),
(1943, 1, 104, '0', '2000-01-01 00:00:01'),
(1944, 1, 105, '0', '2000-01-01 00:00:01'),
(1945, 1, 106, '0', '2000-01-01 00:00:01'),
(1946, 1, 107, '0', '2000-01-01 00:00:01'),
(1947, 1, 26, '0', '2000-01-01 00:00:01'),
(1948, 1, 108, '0', '2000-01-01 00:00:01'),
(1949, 1, 59, '0', '2000-01-01 00:00:01'),
(1950, 1, 109, '0', '2000-01-01 00:00:01'),
(1951, 1, 110, '0', '2000-01-01 00:00:01'),
(1952, 1, 38, '0', '2000-01-01 00:00:01'),
(1953, 1, 55, '0', '2000-01-01 00:00:01'),
(1954, 1, 111, '0', '2000-01-01 00:00:01'),
(1955, 1, 112, '0', '2000-01-01 00:00:01'),
(1956, 1, 113, '0', '2000-01-01 00:00:01'),
(1957, 1, 14, '0', '2000-01-01 00:00:01'),
(1958, 1, 14, '0', '2000-01-01 00:00:01'),
(1959, 1, 22, '0', '2000-01-01 00:00:01'),
(1960, 1, 23, '0', '2000-01-01 00:00:01'),
(1961, 1, 24, '0', '2000-01-01 00:00:01'),
(1962, 1, 25, '0', '2000-01-01 00:00:01'),
(1963, 1, 26, '0', '2000-01-01 00:00:01'),
(1964, 1, 27, '0', '2000-01-01 00:00:01'),
(1965, 1, 28, '0', '2000-01-01 00:00:01'),
(1966, 1, 29, '0', '2000-01-01 00:00:01'),
(1967, 1, 30, '0', '2000-01-01 00:00:01'),
(1968, 1, 31, '0', '2000-01-01 00:00:01'),
(1969, 1, 32, '0', '2000-01-01 00:00:01'),
(1970, 1, 33, '0', '2000-01-01 00:00:01'),
(1971, 1, 34, '0', '2000-01-01 00:00:01'),
(1972, 1, 35, '0', '2000-01-01 00:00:01'),
(1973, 1, 36, '0', '2000-01-01 00:00:01'),
(1974, 1, 37, '0', '2000-01-01 00:00:01'),
(1975, 1, 38, '0', '2000-01-01 00:00:01'),
(1976, 1, 39, '0', '2000-01-01 00:00:01'),
(1977, 1, 40, '0', '2000-01-01 00:00:01'),
(1978, 1, 41, '0', '2000-01-01 00:00:01'),
(1979, 1, 42, '0', '2000-01-01 00:00:01'),
(1980, 1, 43, '0', '2000-01-01 00:00:01'),
(1981, 1, 44, '0', '2000-01-01 00:00:01'),
(1982, 1, 34, '0', '2000-01-01 00:00:01'),
(1983, 1, 45, '0', '2000-01-01 00:00:01'),
(1984, 1, 46, '0', '2000-01-01 00:00:01'),
(1985, 1, 47, '0', '2000-01-01 00:00:01'),
(1986, 1, 48, '0', '2000-01-01 00:00:01'),
(1987, 1, 49, '0', '2000-01-01 00:00:01'),
(1988, 1, 50, '0', '2000-01-01 00:00:01'),
(1989, 1, 51, '0', '2000-01-01 00:00:01'),
(1990, 1, 52, '0', '2000-01-01 00:00:01'),
(1991, 1, 53, '0', '2000-01-01 00:00:01'),
(1992, 1, 54, '0', '2000-01-01 00:00:01'),
(1993, 1, 55, '0', '2000-01-01 00:00:01'),
(1994, 1, 30, '0', '2000-01-01 00:00:01'),
(1995, 1, 56, '0', '2000-01-01 00:00:01'),
(1996, 1, 57, '0', '2000-01-01 00:00:01'),
(1997, 1, 58, '0', '2000-01-01 00:00:01'),
(1998, 1, 59, '0', '2000-01-01 00:00:01'),
(1999, 1, 60, '0', '2000-01-01 00:00:01'),
(2000, 1, 61, '0', '2000-01-01 00:00:01'),
(2001, 1, 62, '0', '2000-01-01 00:00:01'),
(2002, 1, 63, '0', '2000-01-01 00:00:01'),
(2003, 1, 64, '0', '2000-01-01 00:00:01'),
(2004, 1, 65, '0', '2000-01-01 00:00:01'),
(2005, 1, 26, '0', '2000-01-01 00:00:01'),
(2006, 1, 66, '0', '2000-01-01 00:00:01'),
(2007, 1, 66, '0', '2000-01-01 00:00:01'),
(2008, 1, 5, '0', '2000-01-01 00:00:01'),
(2009, 1, 67, '0', '2000-01-01 00:00:01'),
(2010, 1, 68, '0', '2000-01-01 00:00:01'),
(2011, 1, 39, '0', '2000-01-01 00:00:01'),
(2012, 1, 69, '0', '2000-01-01 00:00:01'),
(2013, 1, 70, '0', '2000-01-01 00:00:01'),
(2014, 1, 28, '0', '2000-01-01 00:00:01'),
(2015, 1, 37, '0', '2000-01-01 00:00:01'),
(2016, 1, 71, '0', '2000-01-01 00:00:01'),
(2017, 1, 72, '0', '2000-01-01 00:00:01'),
(2018, 1, 73, '0', '2000-01-01 00:00:01'),
(2019, 1, 74, '0', '2000-01-01 00:00:01'),
(2020, 1, 75, '0', '2000-01-01 00:00:01'),
(2021, 1, 76, '0', '2000-01-01 00:00:01'),
(2022, 1, 77, '0', '2000-01-01 00:00:01'),
(2023, 1, 78, '0', '2000-01-01 00:00:01'),
(2024, 1, 79, '0', '2000-01-01 00:00:01'),
(2025, 1, 80, '0', '2000-01-01 00:00:01'),
(2026, 1, 81, '0', '2000-01-01 00:00:01'),
(2027, 1, 82, '0', '2000-01-01 00:00:01'),
(2028, 1, 83, '0', '2000-01-01 00:00:01'),
(2029, 1, 84, '0', '2000-01-01 00:00:01'),
(2030, 1, 84, '0', '2000-01-01 00:00:01'),
(2031, 1, 85, '0', '2000-01-01 00:00:01'),
(2032, 1, 86, '0', '2000-01-01 00:00:01'),
(2033, 1, 87, '0', '2000-01-01 00:00:01'),
(2034, 1, 88, '0', '2000-01-01 00:00:01'),
(2035, 1, 2, '0', '2000-01-01 00:00:01'),
(2036, 1, 89, '0', '2000-01-01 00:00:01'),
(2037, 1, 90, '0', '2000-01-01 00:00:01'),
(2038, 1, 91, '0', '2000-01-01 00:00:01'),
(2039, 1, 27, '0', '2000-01-01 00:00:01'),
(2040, 1, 92, '0', '2000-01-01 00:00:01'),
(2041, 1, 93, '0', '2000-01-01 00:00:01'),
(2042, 1, 94, '0', '2000-01-01 00:00:01'),
(2043, 1, 95, '0', '2000-01-01 00:00:01'),
(2044, 1, 48, '0', '2000-01-01 00:00:01'),
(2045, 1, 96, '0', '2000-01-01 00:00:01'),
(2046, 1, 97, '0', '2000-01-01 00:00:01'),
(2047, 1, 84, '0', '2000-01-01 00:00:01'),
(2048, 1, 98, '0', '2000-01-01 00:00:01'),
(2049, 1, 99, '0', '2000-01-01 00:00:01'),
(2050, 1, 52, '0', '2000-01-01 00:00:01'),
(2051, 1, 41, '0', '2000-01-01 00:00:01'),
(2052, 1, 100, '0', '2000-01-01 00:00:01'),
(2053, 1, 101, '0', '2000-01-01 00:00:01'),
(2054, 1, 102, '0', '2000-01-01 00:00:01'),
(2055, 1, 103, '0', '2000-01-01 00:00:01'),
(2056, 1, 104, '0', '2000-01-01 00:00:01'),
(2057, 1, 105, '0', '2000-01-01 00:00:01'),
(2058, 1, 106, '0', '2000-01-01 00:00:01'),
(2059, 1, 107, '0', '2000-01-01 00:00:01'),
(2060, 1, 26, '0', '2000-01-01 00:00:01'),
(2061, 1, 108, '0', '2000-01-01 00:00:01'),
(2062, 1, 59, '0', '2000-01-01 00:00:01'),
(2063, 1, 109, '0', '2000-01-01 00:00:01'),
(2064, 1, 110, '0', '2000-01-01 00:00:01'),
(2065, 1, 38, '0', '2000-01-01 00:00:01'),
(2066, 1, 55, '0', '2000-01-01 00:00:01'),
(2067, 1, 111, '0', '2000-01-01 00:00:01'),
(2068, 1, 112, '0', '2000-01-01 00:00:01'),
(2069, 1, 113, '0', '2000-01-01 00:00:01'),
(2070, 1, 14, '0', '2000-01-01 00:00:01'),
(2071, 1, 14, '0', '2000-01-01 00:00:01'),
(2072, 1, 22, '0', '2000-01-01 00:00:01'),
(2073, 1, 23, '0', '2000-01-01 00:00:01'),
(2074, 1, 24, '0', '2000-01-01 00:00:01'),
(2075, 1, 25, '0', '2000-01-01 00:00:01'),
(2076, 1, 26, '0', '2000-01-01 00:00:01'),
(2077, 1, 27, '0', '2000-01-01 00:00:01'),
(2078, 1, 28, '0', '2000-01-01 00:00:01'),
(2079, 1, 29, '0', '2000-01-01 00:00:01'),
(2080, 1, 30, '0', '2000-01-01 00:00:01'),
(2081, 1, 31, '0', '2000-01-01 00:00:01'),
(2082, 1, 32, '0', '2000-01-01 00:00:01'),
(2083, 1, 33, '0', '2000-01-01 00:00:01'),
(2084, 1, 34, '0', '2000-01-01 00:00:01'),
(2085, 1, 35, '0', '2000-01-01 00:00:01'),
(2086, 1, 36, '0', '2000-01-01 00:00:01'),
(2087, 1, 37, '0', '2000-01-01 00:00:01'),
(2088, 1, 38, '0', '2000-01-01 00:00:01'),
(2089, 1, 39, '0', '2000-01-01 00:00:01'),
(2090, 1, 40, '0', '2000-01-01 00:00:01'),
(2091, 1, 41, '0', '2000-01-01 00:00:01'),
(2092, 1, 42, '0', '2000-01-01 00:00:01'),
(2093, 1, 43, '0', '2000-01-01 00:00:01'),
(2094, 1, 44, '0', '2000-01-01 00:00:01'),
(2095, 1, 34, '0', '2000-01-01 00:00:01'),
(2096, 1, 45, '0', '2000-01-01 00:00:01'),
(2097, 1, 46, '0', '2000-01-01 00:00:01'),
(2098, 1, 47, '0', '2000-01-01 00:00:01'),
(2099, 1, 48, '0', '2000-01-01 00:00:01'),
(2100, 1, 49, '0', '2000-01-01 00:00:01'),
(2101, 1, 50, '0', '2000-01-01 00:00:01'),
(2102, 1, 51, '0', '2000-01-01 00:00:01'),
(2103, 1, 52, '0', '2000-01-01 00:00:01'),
(2104, 1, 53, '0', '2000-01-01 00:00:01'),
(2105, 1, 54, '0', '2000-01-01 00:00:01'),
(2106, 1, 55, '0', '2000-01-01 00:00:01'),
(2107, 1, 30, '0', '2000-01-01 00:00:01'),
(2108, 1, 56, '0', '2000-01-01 00:00:01'),
(2109, 1, 57, '0', '2000-01-01 00:00:01'),
(2110, 1, 58, '0', '2000-01-01 00:00:01'),
(2111, 1, 59, '0', '2000-01-01 00:00:01'),
(2112, 1, 60, '0', '2000-01-01 00:00:01'),
(2113, 1, 61, '0', '2000-01-01 00:00:01'),
(2114, 1, 62, '0', '2000-01-01 00:00:01'),
(2115, 1, 63, '0', '2000-01-01 00:00:01'),
(2116, 1, 64, '0', '2000-01-01 00:00:01'),
(2117, 1, 65, '0', '2000-01-01 00:00:01'),
(2118, 1, 26, '0', '2000-01-01 00:00:01'),
(2119, 1, 66, '0', '2000-01-01 00:00:01'),
(2120, 1, 66, '0', '2000-01-01 00:00:01'),
(2121, 1, 5, '0', '2000-01-01 00:00:01'),
(2122, 1, 67, '0', '2000-01-01 00:00:01'),
(2123, 1, 68, '0', '2000-01-01 00:00:01'),
(2124, 1, 39, '0', '2000-01-01 00:00:01'),
(2125, 1, 69, '0', '2000-01-01 00:00:01'),
(2126, 1, 70, '0', '2000-01-01 00:00:01'),
(2127, 1, 28, '0', '2000-01-01 00:00:01'),
(2128, 1, 37, '0', '2000-01-01 00:00:01'),
(2129, 1, 71, '0', '2000-01-01 00:00:01'),
(2130, 1, 72, '0', '2000-01-01 00:00:01'),
(2131, 1, 73, '0', '2000-01-01 00:00:01'),
(2132, 1, 74, '0', '2000-01-01 00:00:01'),
(2133, 1, 75, '0', '2000-01-01 00:00:01'),
(2134, 1, 76, '0', '2000-01-01 00:00:01'),
(2135, 1, 77, '0', '2000-01-01 00:00:01'),
(2136, 1, 78, '0', '2000-01-01 00:00:01'),
(2137, 1, 79, '0', '2000-01-01 00:00:01'),
(2138, 1, 80, '0', '2000-01-01 00:00:01'),
(2139, 1, 81, '0', '2000-01-01 00:00:01'),
(2140, 1, 82, '0', '2000-01-01 00:00:01'),
(2141, 1, 83, '0', '2000-01-01 00:00:01'),
(2142, 1, 84, '0', '2000-01-01 00:00:01'),
(2143, 1, 84, '0', '2000-01-01 00:00:01'),
(2144, 1, 85, '0', '2000-01-01 00:00:01'),
(2145, 1, 86, '0', '2000-01-01 00:00:01'),
(2146, 1, 87, '0', '2000-01-01 00:00:01'),
(2147, 1, 88, '0', '2000-01-01 00:00:01'),
(2148, 1, 2, '0', '2000-01-01 00:00:01'),
(2149, 1, 89, '0', '2000-01-01 00:00:01'),
(2150, 1, 90, '0', '2000-01-01 00:00:01'),
(2151, 1, 91, '0', '2000-01-01 00:00:01'),
(2152, 1, 27, '0', '2000-01-01 00:00:01'),
(2153, 1, 92, '0', '2000-01-01 00:00:01'),
(2154, 1, 93, '0', '2000-01-01 00:00:01'),
(2155, 1, 94, '0', '2000-01-01 00:00:01'),
(2156, 1, 95, '0', '2000-01-01 00:00:01'),
(2157, 1, 48, '0', '2000-01-01 00:00:01'),
(2158, 1, 96, '0', '2000-01-01 00:00:01'),
(2159, 1, 97, '0', '2000-01-01 00:00:01'),
(2160, 1, 84, '0', '2000-01-01 00:00:01'),
(2161, 1, 98, '0', '2000-01-01 00:00:01'),
(2162, 1, 99, '0', '2000-01-01 00:00:01'),
(2163, 1, 52, '0', '2000-01-01 00:00:01'),
(2164, 1, 41, '0', '2000-01-01 00:00:01'),
(2165, 1, 100, '0', '2000-01-01 00:00:01'),
(2166, 1, 101, '0', '2000-01-01 00:00:01'),
(2167, 1, 102, '0', '2000-01-01 00:00:01'),
(2168, 1, 103, '0', '2000-01-01 00:00:01'),
(2169, 1, 104, '0', '2000-01-01 00:00:01'),
(2170, 1, 105, '0', '2000-01-01 00:00:01'),
(2171, 1, 106, '0', '2000-01-01 00:00:01'),
(2172, 1, 107, '0', '2000-01-01 00:00:01'),
(2173, 1, 26, '0', '2000-01-01 00:00:01'),
(2174, 1, 108, '0', '2000-01-01 00:00:01'),
(2175, 1, 59, '0', '2000-01-01 00:00:01'),
(2176, 1, 109, '0', '2000-01-01 00:00:01'),
(2177, 1, 110, '0', '2000-01-01 00:00:01'),
(2178, 1, 38, '0', '2000-01-01 00:00:01'),
(2179, 1, 55, '0', '2000-01-01 00:00:01'),
(2180, 1, 111, '0', '2000-01-01 00:00:01'),
(2181, 1, 112, '0', '2000-01-01 00:00:01'),
(2182, 1, 113, '0', '2000-01-01 00:00:01'),
(2183, 1, 14, '0', '2000-01-01 00:00:01'),
(2184, 1, 14, '0', '2000-01-01 00:00:01'),
(2185, 1, 22, '0', '2000-01-01 00:00:01'),
(2186, 1, 23, '0', '2000-01-01 00:00:01'),
(2187, 1, 24, '0', '2000-01-01 00:00:01'),
(2188, 1, 25, '0', '2000-01-01 00:00:01'),
(2189, 1, 26, '0', '2000-01-01 00:00:01'),
(2190, 1, 27, '0', '2000-01-01 00:00:01'),
(2191, 1, 28, '0', '2000-01-01 00:00:01'),
(2192, 1, 29, '0', '2000-01-01 00:00:01'),
(2193, 1, 30, '0', '2000-01-01 00:00:01'),
(2194, 1, 31, '0', '2000-01-01 00:00:01'),
(2195, 1, 32, '0', '2000-01-01 00:00:01'),
(2196, 1, 33, '0', '2000-01-01 00:00:01'),
(2197, 1, 34, '0', '2000-01-01 00:00:01'),
(2198, 1, 35, '0', '2000-01-01 00:00:01'),
(2199, 1, 36, '0', '2000-01-01 00:00:01'),
(2200, 1, 37, '0', '2000-01-01 00:00:01'),
(2201, 1, 38, '0', '2000-01-01 00:00:01'),
(2202, 1, 39, '0', '2000-01-01 00:00:01'),
(2203, 1, 40, '0', '2000-01-01 00:00:01'),
(2204, 1, 41, '0', '2000-01-01 00:00:01'),
(2205, 1, 42, '0', '2000-01-01 00:00:01'),
(2206, 1, 43, '0', '2000-01-01 00:00:01'),
(2207, 1, 44, '0', '2000-01-01 00:00:01'),
(2208, 1, 34, '0', '2000-01-01 00:00:01'),
(2209, 1, 45, '0', '2000-01-01 00:00:01'),
(2210, 1, 46, '0', '2000-01-01 00:00:01'),
(2211, 1, 47, '0', '2000-01-01 00:00:01'),
(2212, 1, 48, '0', '2000-01-01 00:00:01'),
(2213, 1, 49, '0', '2000-01-01 00:00:01'),
(2214, 1, 50, '0', '2000-01-01 00:00:01'),
(2215, 1, 51, '0', '2000-01-01 00:00:01'),
(2216, 1, 52, '0', '2000-01-01 00:00:01'),
(2217, 1, 53, '0', '2000-01-01 00:00:01'),
(2218, 1, 54, '0', '2000-01-01 00:00:01'),
(2219, 1, 55, '0', '2000-01-01 00:00:01'),
(2220, 1, 30, '0', '2000-01-01 00:00:01'),
(2221, 1, 56, '0', '2000-01-01 00:00:01'),
(2222, 1, 57, '0', '2000-01-01 00:00:01'),
(2223, 1, 58, '0', '2000-01-01 00:00:01'),
(2224, 1, 59, '0', '2000-01-01 00:00:01'),
(2225, 1, 60, '0', '2000-01-01 00:00:01'),
(2226, 1, 61, '0', '2000-01-01 00:00:01'),
(2227, 1, 62, '0', '2000-01-01 00:00:01'),
(2228, 1, 63, '0', '2000-01-01 00:00:01'),
(2229, 1, 64, '0', '2000-01-01 00:00:01'),
(2230, 1, 65, '0', '2000-01-01 00:00:01'),
(2231, 1, 26, '0', '2000-01-01 00:00:01'),
(2232, 1, 66, '0', '2000-01-01 00:00:01'),
(2233, 1, 66, '0', '2000-01-01 00:00:01'),
(2234, 1, 5, '0', '2000-01-01 00:00:01'),
(2235, 1, 67, '0', '2000-01-01 00:00:01'),
(2236, 1, 68, '0', '2000-01-01 00:00:01'),
(2237, 1, 39, '0', '2000-01-01 00:00:01'),
(2238, 1, 69, '0', '2000-01-01 00:00:01'),
(2239, 1, 70, '0', '2000-01-01 00:00:01'),
(2240, 1, 28, '0', '2000-01-01 00:00:01'),
(2241, 1, 37, '0', '2000-01-01 00:00:01'),
(2242, 1, 71, '0', '2000-01-01 00:00:01'),
(2243, 1, 72, '0', '2000-01-01 00:00:01'),
(2244, 1, 73, '0', '2000-01-01 00:00:01'),
(2245, 1, 74, '0', '2000-01-01 00:00:01'),
(2246, 1, 75, '0', '2000-01-01 00:00:01'),
(2247, 1, 76, '0', '2000-01-01 00:00:01'),
(2248, 1, 77, '0', '2000-01-01 00:00:01'),
(2249, 1, 78, '0', '2000-01-01 00:00:01'),
(2250, 1, 79, '0', '2000-01-01 00:00:01'),
(2251, 1, 80, '0', '2000-01-01 00:00:01'),
(2252, 1, 81, '0', '2000-01-01 00:00:01'),
(2253, 1, 82, '0', '2000-01-01 00:00:01'),
(2254, 1, 83, '0', '2000-01-01 00:00:01'),
(2255, 1, 84, '0', '2000-01-01 00:00:01'),
(2256, 1, 84, '0', '2000-01-01 00:00:01'),
(2257, 1, 85, '0', '2000-01-01 00:00:01'),
(2258, 1, 86, '0', '2000-01-01 00:00:01'),
(2259, 1, 87, '0', '2000-01-01 00:00:01'),
(2260, 1, 88, '0', '2000-01-01 00:00:01'),
(2261, 1, 2, '0', '2000-01-01 00:00:01');
INSERT INTO `hoja_asistencia` (`id_hoja_asistencia`, `id_asamblea`, `id_auth_user`, `estado`, `hora`) VALUES
(2262, 1, 89, '0', '2000-01-01 00:00:01'),
(2263, 1, 90, '0', '2000-01-01 00:00:01'),
(2264, 1, 91, '0', '2000-01-01 00:00:01'),
(2265, 1, 27, '0', '2000-01-01 00:00:01'),
(2266, 1, 92, '0', '2000-01-01 00:00:01'),
(2267, 1, 93, '0', '2000-01-01 00:00:01'),
(2268, 1, 94, '0', '2000-01-01 00:00:01'),
(2269, 1, 95, '0', '2000-01-01 00:00:01'),
(2270, 1, 48, '0', '2000-01-01 00:00:01'),
(2271, 1, 96, '0', '2000-01-01 00:00:01'),
(2272, 1, 97, '0', '2000-01-01 00:00:01'),
(2273, 1, 84, '0', '2000-01-01 00:00:01'),
(2274, 1, 98, '0', '2000-01-01 00:00:01'),
(2275, 1, 99, '0', '2000-01-01 00:00:01'),
(2276, 1, 52, '0', '2000-01-01 00:00:01'),
(2277, 1, 41, '0', '2000-01-01 00:00:01'),
(2278, 1, 100, '0', '2000-01-01 00:00:01'),
(2279, 1, 101, '0', '2000-01-01 00:00:01'),
(2280, 1, 102, '0', '2000-01-01 00:00:01'),
(2281, 1, 103, '0', '2000-01-01 00:00:01'),
(2282, 1, 104, '0', '2000-01-01 00:00:01'),
(2283, 1, 105, '0', '2000-01-01 00:00:01'),
(2284, 1, 106, '0', '2000-01-01 00:00:01'),
(2285, 1, 107, '0', '2000-01-01 00:00:01'),
(2286, 1, 26, '0', '2000-01-01 00:00:01'),
(2287, 1, 108, '0', '2000-01-01 00:00:01'),
(2288, 1, 59, '0', '2000-01-01 00:00:01'),
(2289, 1, 109, '0', '2000-01-01 00:00:01'),
(2290, 1, 110, '0', '2000-01-01 00:00:01'),
(2291, 1, 38, '0', '2000-01-01 00:00:01'),
(2292, 1, 55, '0', '2000-01-01 00:00:01'),
(2293, 1, 111, '0', '2000-01-01 00:00:01'),
(2294, 1, 112, '0', '2000-01-01 00:00:01'),
(2295, 1, 113, '0', '2000-01-01 00:00:01'),
(2296, 1, 14, '0', '2000-01-01 00:00:01'),
(2297, 1, 14, '0', '2000-01-01 00:00:01'),
(2298, 1, 22, '0', '2000-01-01 00:00:01'),
(2299, 1, 23, '0', '2000-01-01 00:00:01'),
(2300, 1, 24, '0', '2000-01-01 00:00:01'),
(2301, 1, 25, '0', '2000-01-01 00:00:01'),
(2302, 1, 26, '0', '2000-01-01 00:00:01'),
(2303, 1, 27, '0', '2000-01-01 00:00:01'),
(2304, 1, 28, '0', '2000-01-01 00:00:01'),
(2305, 1, 29, '0', '2000-01-01 00:00:01'),
(2306, 1, 30, '0', '2000-01-01 00:00:01'),
(2307, 1, 31, '0', '2000-01-01 00:00:01'),
(2308, 1, 32, '0', '2000-01-01 00:00:01'),
(2309, 1, 33, '0', '2000-01-01 00:00:01'),
(2310, 1, 34, '0', '2000-01-01 00:00:01'),
(2311, 1, 35, '0', '2000-01-01 00:00:01'),
(2312, 1, 36, '0', '2000-01-01 00:00:01'),
(2313, 1, 37, '0', '2000-01-01 00:00:01'),
(2314, 1, 38, '0', '2000-01-01 00:00:01'),
(2315, 1, 39, '0', '2000-01-01 00:00:01'),
(2316, 1, 40, '0', '2000-01-01 00:00:01'),
(2317, 1, 41, '0', '2000-01-01 00:00:01'),
(2318, 1, 42, '0', '2000-01-01 00:00:01'),
(2319, 1, 43, '0', '2000-01-01 00:00:01'),
(2320, 1, 44, '0', '2000-01-01 00:00:01'),
(2321, 1, 34, '0', '2000-01-01 00:00:01'),
(2322, 1, 45, '0', '2000-01-01 00:00:01'),
(2323, 1, 46, '0', '2000-01-01 00:00:01'),
(2324, 1, 47, '0', '2000-01-01 00:00:01'),
(2325, 1, 48, '0', '2000-01-01 00:00:01'),
(2326, 1, 49, '0', '2000-01-01 00:00:01'),
(2327, 1, 50, '0', '2000-01-01 00:00:01'),
(2328, 1, 51, '0', '2000-01-01 00:00:01'),
(2329, 1, 52, '0', '2000-01-01 00:00:01'),
(2330, 1, 53, '0', '2000-01-01 00:00:01'),
(2331, 1, 54, '0', '2000-01-01 00:00:01'),
(2332, 1, 55, '0', '2000-01-01 00:00:01'),
(2333, 1, 30, '0', '2000-01-01 00:00:01'),
(2334, 1, 56, '0', '2000-01-01 00:00:01'),
(2335, 1, 57, '0', '2000-01-01 00:00:01'),
(2336, 1, 58, '0', '2000-01-01 00:00:01'),
(2337, 1, 59, '0', '2000-01-01 00:00:01'),
(2338, 1, 60, '0', '2000-01-01 00:00:01'),
(2339, 1, 61, '0', '2000-01-01 00:00:01'),
(2340, 1, 62, '0', '2000-01-01 00:00:01'),
(2341, 1, 63, '0', '2000-01-01 00:00:01'),
(2342, 1, 64, '0', '2000-01-01 00:00:01'),
(2343, 1, 65, '0', '2000-01-01 00:00:01'),
(2344, 1, 26, '0', '2000-01-01 00:00:01'),
(2345, 1, 66, '0', '2000-01-01 00:00:01'),
(2346, 1, 66, '0', '2000-01-01 00:00:01'),
(2347, 1, 5, '0', '2000-01-01 00:00:01'),
(2348, 1, 67, '0', '2000-01-01 00:00:01'),
(2349, 1, 68, '0', '2000-01-01 00:00:01'),
(2350, 1, 39, '0', '2000-01-01 00:00:01'),
(2351, 1, 69, '0', '2000-01-01 00:00:01'),
(2352, 1, 70, '0', '2000-01-01 00:00:01'),
(2353, 1, 28, '0', '2000-01-01 00:00:01'),
(2354, 1, 37, '0', '2000-01-01 00:00:01'),
(2355, 1, 71, '0', '2000-01-01 00:00:01'),
(2356, 1, 72, '0', '2000-01-01 00:00:01'),
(2357, 1, 73, '0', '2000-01-01 00:00:01'),
(2358, 1, 74, '0', '2000-01-01 00:00:01'),
(2359, 1, 75, '0', '2000-01-01 00:00:01'),
(2360, 1, 76, '0', '2000-01-01 00:00:01'),
(2361, 1, 77, '0', '2000-01-01 00:00:01'),
(2362, 1, 78, '0', '2000-01-01 00:00:01'),
(2363, 1, 79, '0', '2000-01-01 00:00:01'),
(2364, 1, 80, '0', '2000-01-01 00:00:01'),
(2365, 1, 81, '0', '2000-01-01 00:00:01'),
(2366, 1, 82, '0', '2000-01-01 00:00:01'),
(2367, 1, 83, '0', '2000-01-01 00:00:01'),
(2368, 1, 84, '0', '2000-01-01 00:00:01'),
(2369, 1, 84, '0', '2000-01-01 00:00:01'),
(2370, 1, 85, '0', '2000-01-01 00:00:01'),
(2371, 1, 86, '0', '2000-01-01 00:00:01'),
(2372, 1, 87, '0', '2000-01-01 00:00:01'),
(2373, 1, 88, '0', '2000-01-01 00:00:01'),
(2374, 1, 2, '0', '2000-01-01 00:00:01'),
(2375, 1, 89, '0', '2000-01-01 00:00:01'),
(2376, 1, 90, '0', '2000-01-01 00:00:01'),
(2377, 1, 91, '0', '2000-01-01 00:00:01'),
(2378, 1, 27, '0', '2000-01-01 00:00:01'),
(2379, 1, 92, '0', '2000-01-01 00:00:01'),
(2380, 1, 93, '0', '2000-01-01 00:00:01'),
(2381, 1, 94, '0', '2000-01-01 00:00:01'),
(2382, 1, 95, '0', '2000-01-01 00:00:01'),
(2383, 1, 48, '0', '2000-01-01 00:00:01'),
(2384, 1, 96, '0', '2000-01-01 00:00:01'),
(2385, 1, 97, '0', '2000-01-01 00:00:01'),
(2386, 1, 84, '0', '2000-01-01 00:00:01'),
(2387, 1, 98, '0', '2000-01-01 00:00:01'),
(2388, 1, 99, '0', '2000-01-01 00:00:01'),
(2389, 1, 52, '0', '2000-01-01 00:00:01'),
(2390, 1, 41, '0', '2000-01-01 00:00:01'),
(2391, 1, 100, '0', '2000-01-01 00:00:01'),
(2392, 1, 101, '0', '2000-01-01 00:00:01'),
(2393, 1, 102, '0', '2000-01-01 00:00:01'),
(2394, 1, 103, '0', '2000-01-01 00:00:01'),
(2395, 1, 104, '0', '2000-01-01 00:00:01'),
(2396, 1, 105, '0', '2000-01-01 00:00:01'),
(2397, 1, 106, '0', '2000-01-01 00:00:01'),
(2398, 1, 107, '0', '2000-01-01 00:00:01'),
(2399, 1, 26, '0', '2000-01-01 00:00:01'),
(2400, 1, 108, '0', '2000-01-01 00:00:01'),
(2401, 1, 59, '0', '2000-01-01 00:00:01'),
(2402, 1, 109, '0', '2000-01-01 00:00:01'),
(2403, 1, 110, '0', '2000-01-01 00:00:01'),
(2404, 1, 38, '0', '2000-01-01 00:00:01'),
(2405, 1, 55, '0', '2000-01-01 00:00:01'),
(2406, 1, 111, '0', '2000-01-01 00:00:01'),
(2407, 1, 112, '0', '2000-01-01 00:00:01'),
(2408, 1, 113, '0', '2000-01-01 00:00:01'),
(2409, 1, 14, '0', '2000-01-01 00:00:01'),
(2410, 1, 14, '0', '2000-01-01 00:00:01'),
(2411, 1, 22, '0', '2000-01-01 00:00:01'),
(2412, 1, 23, '0', '2000-01-01 00:00:01'),
(2413, 1, 24, '0', '2000-01-01 00:00:01'),
(2414, 1, 25, '0', '2000-01-01 00:00:01'),
(2415, 1, 26, '0', '2000-01-01 00:00:01'),
(2416, 1, 27, '0', '2000-01-01 00:00:01'),
(2417, 1, 28, '0', '2000-01-01 00:00:01'),
(2418, 1, 29, '0', '2000-01-01 00:00:01'),
(2419, 1, 30, '0', '2000-01-01 00:00:01'),
(2420, 1, 31, '0', '2000-01-01 00:00:01'),
(2421, 1, 32, '0', '2000-01-01 00:00:01'),
(2422, 1, 33, '0', '2000-01-01 00:00:01'),
(2423, 1, 34, '0', '2000-01-01 00:00:01'),
(2424, 1, 35, '0', '2000-01-01 00:00:01'),
(2425, 1, 36, '0', '2000-01-01 00:00:01'),
(2426, 1, 37, '0', '2000-01-01 00:00:01'),
(2427, 1, 38, '0', '2000-01-01 00:00:01'),
(2428, 1, 39, '0', '2000-01-01 00:00:01'),
(2429, 1, 40, '0', '2000-01-01 00:00:01'),
(2430, 1, 41, '0', '2000-01-01 00:00:01'),
(2431, 1, 42, '0', '2000-01-01 00:00:01'),
(2432, 1, 43, '0', '2000-01-01 00:00:01'),
(2433, 1, 44, '0', '2000-01-01 00:00:01'),
(2434, 1, 34, '0', '2000-01-01 00:00:01'),
(2435, 1, 45, '0', '2000-01-01 00:00:01'),
(2436, 1, 46, '0', '2000-01-01 00:00:01'),
(2437, 1, 47, '0', '2000-01-01 00:00:01'),
(2438, 1, 48, '0', '2000-01-01 00:00:01'),
(2439, 1, 49, '0', '2000-01-01 00:00:01'),
(2440, 1, 50, '0', '2000-01-01 00:00:01'),
(2441, 1, 51, '0', '2000-01-01 00:00:01'),
(2442, 1, 52, '0', '2000-01-01 00:00:01'),
(2443, 1, 53, '0', '2000-01-01 00:00:01'),
(2444, 1, 54, '0', '2000-01-01 00:00:01'),
(2445, 1, 55, '0', '2000-01-01 00:00:01'),
(2446, 1, 30, '0', '2000-01-01 00:00:01'),
(2447, 1, 56, '0', '2000-01-01 00:00:01'),
(2448, 1, 57, '0', '2000-01-01 00:00:01'),
(2449, 1, 58, '0', '2000-01-01 00:00:01'),
(2450, 1, 59, '0', '2000-01-01 00:00:01'),
(2451, 1, 60, '0', '2000-01-01 00:00:01'),
(2452, 1, 61, '0', '2000-01-01 00:00:01'),
(2453, 1, 62, '0', '2000-01-01 00:00:01'),
(2454, 1, 63, '0', '2000-01-01 00:00:01'),
(2455, 1, 64, '0', '2000-01-01 00:00:01'),
(2456, 1, 65, '0', '2000-01-01 00:00:01'),
(2457, 1, 26, '0', '2000-01-01 00:00:01'),
(2458, 1, 66, '0', '2000-01-01 00:00:01'),
(2459, 1, 66, '0', '2000-01-01 00:00:01'),
(2460, 1, 5, '0', '2000-01-01 00:00:01'),
(2461, 1, 67, '0', '2000-01-01 00:00:01'),
(2462, 1, 68, '0', '2000-01-01 00:00:01'),
(2463, 1, 39, '0', '2000-01-01 00:00:01'),
(2464, 1, 69, '0', '2000-01-01 00:00:01'),
(2465, 1, 70, '0', '2000-01-01 00:00:01'),
(2466, 1, 28, '0', '2000-01-01 00:00:01'),
(2467, 1, 37, '0', '2000-01-01 00:00:01'),
(2468, 1, 71, '0', '2000-01-01 00:00:01'),
(2469, 1, 72, '0', '2000-01-01 00:00:01'),
(2470, 1, 73, '0', '2000-01-01 00:00:01'),
(2471, 1, 74, '0', '2000-01-01 00:00:01'),
(2472, 1, 75, '0', '2000-01-01 00:00:01'),
(2473, 1, 76, '0', '2000-01-01 00:00:01'),
(2474, 1, 77, '0', '2000-01-01 00:00:01'),
(2475, 1, 78, '0', '2000-01-01 00:00:01'),
(2476, 1, 79, '0', '2000-01-01 00:00:01'),
(2477, 1, 80, '0', '2000-01-01 00:00:01'),
(2478, 1, 81, '0', '2000-01-01 00:00:01'),
(2479, 1, 82, '0', '2000-01-01 00:00:01'),
(2480, 1, 83, '0', '2000-01-01 00:00:01'),
(2481, 1, 84, '0', '2000-01-01 00:00:01'),
(2482, 1, 84, '0', '2000-01-01 00:00:01'),
(2483, 1, 85, '0', '2000-01-01 00:00:01'),
(2484, 1, 86, '0', '2000-01-01 00:00:01'),
(2485, 1, 87, '0', '2000-01-01 00:00:01'),
(2486, 1, 88, '0', '2000-01-01 00:00:01'),
(2487, 1, 2, '0', '2000-01-01 00:00:01'),
(2488, 1, 89, '0', '2000-01-01 00:00:01'),
(2489, 1, 90, '0', '2000-01-01 00:00:01'),
(2490, 1, 91, '0', '2000-01-01 00:00:01'),
(2491, 1, 27, '0', '2000-01-01 00:00:01'),
(2492, 1, 92, '0', '2000-01-01 00:00:01'),
(2493, 1, 93, '0', '2000-01-01 00:00:01'),
(2494, 1, 94, '0', '2000-01-01 00:00:01'),
(2495, 1, 95, '0', '2000-01-01 00:00:01'),
(2496, 1, 48, '0', '2000-01-01 00:00:01'),
(2497, 1, 96, '0', '2000-01-01 00:00:01'),
(2498, 1, 97, '0', '2000-01-01 00:00:01'),
(2499, 1, 84, '0', '2000-01-01 00:00:01'),
(2500, 1, 98, '0', '2000-01-01 00:00:01'),
(2501, 1, 99, '0', '2000-01-01 00:00:01'),
(2502, 1, 52, '0', '2000-01-01 00:00:01'),
(2503, 1, 41, '0', '2000-01-01 00:00:01'),
(2504, 1, 100, '0', '2000-01-01 00:00:01'),
(2505, 1, 101, '0', '2000-01-01 00:00:01'),
(2506, 1, 102, '0', '2000-01-01 00:00:01'),
(2507, 1, 103, '0', '2000-01-01 00:00:01'),
(2508, 1, 104, '0', '2000-01-01 00:00:01'),
(2509, 1, 105, '0', '2000-01-01 00:00:01'),
(2510, 1, 106, '0', '2000-01-01 00:00:01'),
(2511, 1, 107, '0', '2000-01-01 00:00:01'),
(2512, 1, 26, '0', '2000-01-01 00:00:01'),
(2513, 1, 108, '0', '2000-01-01 00:00:01'),
(2514, 1, 59, '0', '2000-01-01 00:00:01'),
(2515, 1, 109, '0', '2000-01-01 00:00:01'),
(2516, 1, 110, '0', '2000-01-01 00:00:01'),
(2517, 1, 38, '0', '2000-01-01 00:00:01'),
(2518, 1, 55, '0', '2000-01-01 00:00:01'),
(2519, 1, 111, '0', '2000-01-01 00:00:01'),
(2520, 1, 112, '0', '2000-01-01 00:00:01'),
(2521, 1, 113, '0', '2000-01-01 00:00:01'),
(2522, 1, 14, '0', '2000-01-01 00:00:01'),
(2523, 1, 14, '0', '2000-01-01 00:00:01'),
(2524, 1, 22, '0', '2000-01-01 00:00:01'),
(2525, 1, 23, '0', '2000-01-01 00:00:01'),
(2526, 1, 24, '0', '2000-01-01 00:00:01'),
(2527, 1, 25, '0', '2000-01-01 00:00:01'),
(2528, 1, 26, '0', '2000-01-01 00:00:01'),
(2529, 1, 27, '0', '2000-01-01 00:00:01'),
(2530, 1, 28, '0', '2000-01-01 00:00:01'),
(2531, 1, 29, '0', '2000-01-01 00:00:01'),
(2532, 1, 30, '0', '2000-01-01 00:00:01'),
(2533, 1, 31, '0', '2000-01-01 00:00:01'),
(2534, 1, 32, '0', '2000-01-01 00:00:01'),
(2535, 1, 33, '0', '2000-01-01 00:00:01'),
(2536, 1, 34, '0', '2000-01-01 00:00:01'),
(2537, 1, 35, '0', '2000-01-01 00:00:01'),
(2538, 1, 36, '0', '2000-01-01 00:00:01'),
(2539, 1, 37, '0', '2000-01-01 00:00:01'),
(2540, 1, 38, '0', '2000-01-01 00:00:01'),
(2541, 1, 39, '0', '2000-01-01 00:00:01'),
(2542, 1, 40, '0', '2000-01-01 00:00:01'),
(2543, 1, 41, '0', '2000-01-01 00:00:01'),
(2544, 1, 42, '0', '2000-01-01 00:00:01'),
(2545, 1, 43, '0', '2000-01-01 00:00:01'),
(2546, 1, 44, '0', '2000-01-01 00:00:01'),
(2547, 1, 34, '0', '2000-01-01 00:00:01'),
(2548, 1, 45, '0', '2000-01-01 00:00:01'),
(2549, 1, 46, '0', '2000-01-01 00:00:01'),
(2550, 1, 47, '0', '2000-01-01 00:00:01'),
(2551, 1, 48, '0', '2000-01-01 00:00:01'),
(2552, 1, 49, '0', '2000-01-01 00:00:01'),
(2553, 1, 50, '0', '2000-01-01 00:00:01'),
(2554, 1, 51, '0', '2000-01-01 00:00:01'),
(2555, 1, 52, '0', '2000-01-01 00:00:01'),
(2556, 1, 53, '0', '2000-01-01 00:00:01'),
(2557, 1, 54, '0', '2000-01-01 00:00:01'),
(2558, 1, 55, '0', '2000-01-01 00:00:01'),
(2559, 1, 30, '0', '2000-01-01 00:00:01'),
(2560, 1, 56, '0', '2000-01-01 00:00:01'),
(2561, 1, 57, '0', '2000-01-01 00:00:01'),
(2562, 1, 58, '0', '2000-01-01 00:00:01'),
(2563, 1, 59, '0', '2000-01-01 00:00:01'),
(2564, 1, 60, '0', '2000-01-01 00:00:01'),
(2565, 1, 61, '0', '2000-01-01 00:00:01'),
(2566, 1, 62, '0', '2000-01-01 00:00:01'),
(2567, 1, 63, '0', '2000-01-01 00:00:01'),
(2568, 1, 64, '0', '2000-01-01 00:00:01'),
(2569, 1, 65, '0', '2000-01-01 00:00:01'),
(2570, 1, 26, '0', '2000-01-01 00:00:01'),
(2571, 1, 66, '0', '2000-01-01 00:00:01'),
(2572, 1, 66, '0', '2000-01-01 00:00:01'),
(2573, 1, 5, '0', '2000-01-01 00:00:01'),
(2574, 1, 67, '0', '2000-01-01 00:00:01'),
(2575, 1, 68, '0', '2000-01-01 00:00:01'),
(2576, 1, 39, '0', '2000-01-01 00:00:01'),
(2577, 1, 69, '0', '2000-01-01 00:00:01'),
(2578, 1, 70, '0', '2000-01-01 00:00:01'),
(2579, 1, 28, '0', '2000-01-01 00:00:01'),
(2580, 1, 37, '0', '2000-01-01 00:00:01'),
(2581, 1, 71, '0', '2000-01-01 00:00:01'),
(2582, 1, 72, '0', '2000-01-01 00:00:01'),
(2583, 1, 73, '0', '2000-01-01 00:00:01'),
(2584, 1, 74, '0', '2000-01-01 00:00:01'),
(2585, 1, 75, '0', '2000-01-01 00:00:01'),
(2586, 1, 76, '0', '2000-01-01 00:00:01'),
(2587, 1, 77, '0', '2000-01-01 00:00:01'),
(2588, 1, 78, '0', '2000-01-01 00:00:01'),
(2589, 1, 79, '0', '2000-01-01 00:00:01'),
(2590, 1, 80, '0', '2000-01-01 00:00:01'),
(2591, 1, 81, '0', '2000-01-01 00:00:01'),
(2592, 1, 82, '0', '2000-01-01 00:00:01'),
(2593, 1, 83, '0', '2000-01-01 00:00:01'),
(2594, 1, 84, '0', '2000-01-01 00:00:01'),
(2595, 1, 84, '0', '2000-01-01 00:00:01'),
(2596, 1, 85, '0', '2000-01-01 00:00:01'),
(2597, 1, 86, '0', '2000-01-01 00:00:01'),
(2598, 1, 87, '0', '2000-01-01 00:00:01'),
(2599, 1, 88, '0', '2000-01-01 00:00:01'),
(2600, 1, 2, '0', '2000-01-01 00:00:01'),
(2601, 1, 89, '0', '2000-01-01 00:00:01'),
(2602, 1, 90, '0', '2000-01-01 00:00:01'),
(2603, 1, 91, '0', '2000-01-01 00:00:01'),
(2604, 1, 27, '0', '2000-01-01 00:00:01'),
(2605, 1, 92, '0', '2000-01-01 00:00:01'),
(2606, 1, 93, '0', '2000-01-01 00:00:01'),
(2607, 1, 94, '0', '2000-01-01 00:00:01'),
(2608, 1, 95, '0', '2000-01-01 00:00:01'),
(2609, 1, 48, '0', '2000-01-01 00:00:01'),
(2610, 1, 96, '0', '2000-01-01 00:00:01'),
(2611, 1, 97, '0', '2000-01-01 00:00:01'),
(2612, 1, 84, '0', '2000-01-01 00:00:01'),
(2613, 1, 98, '0', '2000-01-01 00:00:01'),
(2614, 1, 99, '0', '2000-01-01 00:00:01'),
(2615, 1, 52, '0', '2000-01-01 00:00:01'),
(2616, 1, 41, '0', '2000-01-01 00:00:01'),
(2617, 1, 100, '0', '2000-01-01 00:00:01'),
(2618, 1, 101, '0', '2000-01-01 00:00:01'),
(2619, 1, 102, '0', '2000-01-01 00:00:01'),
(2620, 1, 103, '0', '2000-01-01 00:00:01'),
(2621, 1, 104, '0', '2000-01-01 00:00:01'),
(2622, 1, 105, '0', '2000-01-01 00:00:01'),
(2623, 1, 106, '0', '2000-01-01 00:00:01'),
(2624, 1, 107, '0', '2000-01-01 00:00:01'),
(2625, 1, 26, '0', '2000-01-01 00:00:01'),
(2626, 1, 108, '0', '2000-01-01 00:00:01'),
(2627, 1, 59, '0', '2000-01-01 00:00:01'),
(2628, 1, 109, '0', '2000-01-01 00:00:01'),
(2629, 1, 110, '0', '2000-01-01 00:00:01'),
(2630, 1, 38, '0', '2000-01-01 00:00:01'),
(2631, 1, 55, '0', '2000-01-01 00:00:01'),
(2632, 1, 111, '0', '2000-01-01 00:00:01'),
(2633, 1, 112, '0', '2000-01-01 00:00:01'),
(2634, 1, 113, '0', '2000-01-01 00:00:01'),
(2635, 1, 14, '0', '2000-01-01 00:00:01'),
(2636, 1, 14, '0', '2000-01-01 00:00:01'),
(2637, 1, 22, '0', '2000-01-01 00:00:01'),
(2638, 1, 23, '0', '2000-01-01 00:00:01'),
(2639, 1, 24, '0', '2000-01-01 00:00:01'),
(2640, 1, 25, '0', '2000-01-01 00:00:01'),
(2641, 1, 26, '0', '2000-01-01 00:00:01'),
(2642, 1, 27, '0', '2000-01-01 00:00:01'),
(2643, 1, 28, '0', '2000-01-01 00:00:01'),
(2644, 1, 29, '0', '2000-01-01 00:00:01'),
(2645, 1, 30, '0', '2000-01-01 00:00:01'),
(2646, 1, 31, '0', '2000-01-01 00:00:01'),
(2647, 1, 32, '0', '2000-01-01 00:00:01'),
(2648, 1, 33, '0', '2000-01-01 00:00:01'),
(2649, 1, 34, '0', '2000-01-01 00:00:01'),
(2650, 1, 35, '0', '2000-01-01 00:00:01'),
(2651, 1, 36, '0', '2000-01-01 00:00:01'),
(2652, 1, 37, '0', '2000-01-01 00:00:01'),
(2653, 1, 38, '0', '2000-01-01 00:00:01'),
(2654, 1, 39, '0', '2000-01-01 00:00:01'),
(2655, 1, 40, '0', '2000-01-01 00:00:01'),
(2656, 1, 41, '0', '2000-01-01 00:00:01'),
(2657, 1, 42, '0', '2000-01-01 00:00:01'),
(2658, 1, 43, '0', '2000-01-01 00:00:01'),
(2659, 1, 44, '0', '2000-01-01 00:00:01'),
(2660, 1, 34, '0', '2000-01-01 00:00:01'),
(2661, 1, 45, '0', '2000-01-01 00:00:01'),
(2662, 1, 46, '0', '2000-01-01 00:00:01'),
(2663, 1, 47, '0', '2000-01-01 00:00:01'),
(2664, 1, 48, '0', '2000-01-01 00:00:01'),
(2665, 1, 49, '0', '2000-01-01 00:00:01'),
(2666, 1, 50, '0', '2000-01-01 00:00:01'),
(2667, 1, 51, '0', '2000-01-01 00:00:01'),
(2668, 1, 52, '0', '2000-01-01 00:00:01'),
(2669, 1, 53, '0', '2000-01-01 00:00:01'),
(2670, 1, 54, '0', '2000-01-01 00:00:01'),
(2671, 1, 55, '0', '2000-01-01 00:00:01'),
(2672, 1, 30, '0', '2000-01-01 00:00:01'),
(2673, 1, 56, '0', '2000-01-01 00:00:01'),
(2674, 1, 57, '0', '2000-01-01 00:00:01'),
(2675, 1, 58, '0', '2000-01-01 00:00:01'),
(2676, 1, 59, '0', '2000-01-01 00:00:01'),
(2677, 1, 60, '0', '2000-01-01 00:00:01'),
(2678, 1, 61, '0', '2000-01-01 00:00:01'),
(2679, 1, 62, '0', '2000-01-01 00:00:01'),
(2680, 1, 63, '0', '2000-01-01 00:00:01'),
(2681, 1, 64, '0', '2000-01-01 00:00:01'),
(2682, 1, 65, '0', '2000-01-01 00:00:01'),
(2683, 1, 26, '0', '2000-01-01 00:00:01'),
(2684, 1, 66, '0', '2000-01-01 00:00:01'),
(2685, 1, 66, '0', '2000-01-01 00:00:01'),
(2686, 1, 5, '0', '2000-01-01 00:00:01'),
(2687, 1, 67, '0', '2000-01-01 00:00:01'),
(2688, 1, 68, '0', '2000-01-01 00:00:01'),
(2689, 1, 39, '0', '2000-01-01 00:00:01'),
(2690, 1, 69, '0', '2000-01-01 00:00:01'),
(2691, 1, 70, '0', '2000-01-01 00:00:01'),
(2692, 1, 28, '0', '2000-01-01 00:00:01'),
(2693, 1, 37, '0', '2000-01-01 00:00:01'),
(2694, 1, 71, '0', '2000-01-01 00:00:01'),
(2695, 1, 72, '0', '2000-01-01 00:00:01'),
(2696, 1, 73, '0', '2000-01-01 00:00:01'),
(2697, 1, 74, '0', '2000-01-01 00:00:01'),
(2698, 1, 75, '0', '2000-01-01 00:00:01'),
(2699, 1, 76, '0', '2000-01-01 00:00:01'),
(2700, 1, 77, '0', '2000-01-01 00:00:01'),
(2701, 1, 78, '0', '2000-01-01 00:00:01'),
(2702, 1, 79, '0', '2000-01-01 00:00:01'),
(2703, 1, 80, '0', '2000-01-01 00:00:01'),
(2704, 1, 81, '0', '2000-01-01 00:00:01'),
(2705, 1, 82, '0', '2000-01-01 00:00:01'),
(2706, 1, 83, '0', '2000-01-01 00:00:01'),
(2707, 1, 84, '0', '2000-01-01 00:00:01'),
(2708, 1, 84, '0', '2000-01-01 00:00:01'),
(2709, 1, 85, '0', '2000-01-01 00:00:01'),
(2710, 1, 86, '0', '2000-01-01 00:00:01'),
(2711, 1, 87, '0', '2000-01-01 00:00:01'),
(2712, 1, 88, '0', '2000-01-01 00:00:01'),
(2713, 1, 2, '0', '2000-01-01 00:00:01'),
(2714, 1, 89, '0', '2000-01-01 00:00:01'),
(2715, 1, 90, '0', '2000-01-01 00:00:01'),
(2716, 1, 91, '0', '2000-01-01 00:00:01'),
(2717, 1, 27, '0', '2000-01-01 00:00:01'),
(2718, 1, 92, '0', '2000-01-01 00:00:01'),
(2719, 1, 93, '0', '2000-01-01 00:00:01'),
(2720, 1, 94, '0', '2000-01-01 00:00:01'),
(2721, 1, 95, '0', '2000-01-01 00:00:01'),
(2722, 1, 48, '0', '2000-01-01 00:00:01'),
(2723, 1, 96, '0', '2000-01-01 00:00:01'),
(2724, 1, 97, '0', '2000-01-01 00:00:01'),
(2725, 1, 84, '0', '2000-01-01 00:00:01'),
(2726, 1, 98, '0', '2000-01-01 00:00:01'),
(2727, 1, 99, '0', '2000-01-01 00:00:01'),
(2728, 1, 52, '0', '2000-01-01 00:00:01'),
(2729, 1, 41, '0', '2000-01-01 00:00:01'),
(2730, 1, 100, '0', '2000-01-01 00:00:01'),
(2731, 1, 101, '0', '2000-01-01 00:00:01'),
(2732, 1, 102, '0', '2000-01-01 00:00:01'),
(2733, 1, 103, '0', '2000-01-01 00:00:01'),
(2734, 1, 104, '0', '2000-01-01 00:00:01'),
(2735, 1, 105, '0', '2000-01-01 00:00:01'),
(2736, 1, 106, '0', '2000-01-01 00:00:01'),
(2737, 1, 107, '0', '2000-01-01 00:00:01'),
(2738, 1, 26, '0', '2000-01-01 00:00:01'),
(2739, 1, 108, '0', '2000-01-01 00:00:01'),
(2740, 1, 59, '0', '2000-01-01 00:00:01'),
(2741, 1, 109, '0', '2000-01-01 00:00:01'),
(2742, 1, 110, '0', '2000-01-01 00:00:01'),
(2743, 1, 38, '0', '2000-01-01 00:00:01'),
(2744, 1, 55, '0', '2000-01-01 00:00:01'),
(2745, 1, 111, '0', '2000-01-01 00:00:01'),
(2746, 1, 112, '0', '2000-01-01 00:00:01'),
(2747, 1, 113, '0', '2000-01-01 00:00:01'),
(2748, 1, 14, '0', '2000-01-01 00:00:01'),
(2749, 1, 14, '0', '2000-01-01 00:00:01'),
(2750, 1, 22, '0', '2000-01-01 00:00:01'),
(2751, 1, 23, '0', '2000-01-01 00:00:01'),
(2752, 1, 24, '0', '2000-01-01 00:00:01'),
(2753, 1, 25, '0', '2000-01-01 00:00:01'),
(2754, 1, 26, '0', '2000-01-01 00:00:01'),
(2755, 1, 27, '0', '2000-01-01 00:00:01'),
(2756, 1, 28, '0', '2000-01-01 00:00:01'),
(2757, 1, 29, '0', '2000-01-01 00:00:01'),
(2758, 1, 30, '0', '2000-01-01 00:00:01'),
(2759, 1, 31, '0', '2000-01-01 00:00:01'),
(2760, 1, 32, '0', '2000-01-01 00:00:01'),
(2761, 1, 33, '0', '2000-01-01 00:00:01'),
(2762, 1, 34, '0', '2000-01-01 00:00:01'),
(2763, 1, 35, '0', '2000-01-01 00:00:01'),
(2764, 1, 36, '0', '2000-01-01 00:00:01'),
(2765, 1, 37, '0', '2000-01-01 00:00:01'),
(2766, 1, 38, '0', '2000-01-01 00:00:01'),
(2767, 1, 39, '0', '2000-01-01 00:00:01'),
(2768, 1, 40, '0', '2000-01-01 00:00:01'),
(2769, 1, 41, '0', '2000-01-01 00:00:01'),
(2770, 1, 42, '0', '2000-01-01 00:00:01'),
(2771, 1, 43, '0', '2000-01-01 00:00:01'),
(2772, 1, 44, '0', '2000-01-01 00:00:01'),
(2773, 1, 34, '0', '2000-01-01 00:00:01'),
(2774, 1, 45, '0', '2000-01-01 00:00:01'),
(2775, 1, 46, '0', '2000-01-01 00:00:01'),
(2776, 1, 47, '0', '2000-01-01 00:00:01'),
(2777, 1, 48, '0', '2000-01-01 00:00:01'),
(2778, 1, 49, '0', '2000-01-01 00:00:01'),
(2779, 1, 50, '0', '2000-01-01 00:00:01'),
(2780, 1, 51, '0', '2000-01-01 00:00:01'),
(2781, 1, 52, '0', '2000-01-01 00:00:01'),
(2782, 1, 53, '0', '2000-01-01 00:00:01'),
(2783, 1, 54, '0', '2000-01-01 00:00:01'),
(2784, 1, 55, '0', '2000-01-01 00:00:01'),
(2785, 1, 30, '0', '2000-01-01 00:00:01'),
(2786, 1, 56, '0', '2000-01-01 00:00:01'),
(2787, 1, 57, '0', '2000-01-01 00:00:01'),
(2788, 1, 58, '0', '2000-01-01 00:00:01'),
(2789, 1, 59, '0', '2000-01-01 00:00:01'),
(2790, 1, 60, '0', '2000-01-01 00:00:01'),
(2791, 1, 61, '0', '2000-01-01 00:00:01'),
(2792, 1, 62, '0', '2000-01-01 00:00:01'),
(2793, 1, 63, '0', '2000-01-01 00:00:01'),
(2794, 1, 64, '0', '2000-01-01 00:00:01'),
(2795, 1, 65, '0', '2000-01-01 00:00:01'),
(2796, 1, 26, '0', '2000-01-01 00:00:01'),
(2797, 1, 66, '0', '2000-01-01 00:00:01'),
(2798, 1, 66, '0', '2000-01-01 00:00:01'),
(2799, 1, 5, '0', '2000-01-01 00:00:01'),
(2800, 1, 67, '0', '2000-01-01 00:00:01'),
(2801, 1, 68, '0', '2000-01-01 00:00:01'),
(2802, 1, 39, '0', '2000-01-01 00:00:01'),
(2803, 1, 69, '0', '2000-01-01 00:00:01'),
(2804, 1, 70, '0', '2000-01-01 00:00:01'),
(2805, 1, 28, '0', '2000-01-01 00:00:01'),
(2806, 1, 37, '0', '2000-01-01 00:00:01'),
(2807, 1, 71, '0', '2000-01-01 00:00:01'),
(2808, 1, 72, '0', '2000-01-01 00:00:01'),
(2809, 1, 73, '0', '2000-01-01 00:00:01'),
(2810, 1, 74, '0', '2000-01-01 00:00:01'),
(2811, 1, 75, '0', '2000-01-01 00:00:01'),
(2812, 1, 76, '0', '2000-01-01 00:00:01'),
(2813, 1, 77, '0', '2000-01-01 00:00:01'),
(2814, 1, 78, '0', '2000-01-01 00:00:01'),
(2815, 1, 79, '0', '2000-01-01 00:00:01'),
(2816, 1, 80, '0', '2000-01-01 00:00:01'),
(2817, 1, 81, '0', '2000-01-01 00:00:01'),
(2818, 1, 82, '0', '2000-01-01 00:00:01'),
(2819, 1, 83, '0', '2000-01-01 00:00:01'),
(2820, 1, 84, '0', '2000-01-01 00:00:01'),
(2821, 1, 84, '0', '2000-01-01 00:00:01'),
(2822, 1, 85, '0', '2000-01-01 00:00:01'),
(2823, 1, 86, '0', '2000-01-01 00:00:01'),
(2824, 1, 87, '0', '2000-01-01 00:00:01'),
(2825, 1, 88, '0', '2000-01-01 00:00:01'),
(2826, 1, 2, '0', '2000-01-01 00:00:01'),
(2827, 1, 89, '0', '2000-01-01 00:00:01'),
(2828, 1, 90, '0', '2000-01-01 00:00:01'),
(2829, 1, 91, '0', '2000-01-01 00:00:01'),
(2830, 1, 27, '0', '2000-01-01 00:00:01'),
(2831, 1, 92, '0', '2000-01-01 00:00:01'),
(2832, 1, 93, '0', '2000-01-01 00:00:01'),
(2833, 1, 94, '0', '2000-01-01 00:00:01'),
(2834, 1, 95, '0', '2000-01-01 00:00:01'),
(2835, 1, 48, '0', '2000-01-01 00:00:01'),
(2836, 1, 96, '0', '2000-01-01 00:00:01'),
(2837, 1, 97, '0', '2000-01-01 00:00:01'),
(2838, 1, 84, '0', '2000-01-01 00:00:01'),
(2839, 1, 98, '0', '2000-01-01 00:00:01'),
(2840, 1, 99, '0', '2000-01-01 00:00:01'),
(2841, 1, 52, '0', '2000-01-01 00:00:01'),
(2842, 1, 41, '0', '2000-01-01 00:00:01'),
(2843, 1, 100, '0', '2000-01-01 00:00:01'),
(2844, 1, 101, '0', '2000-01-01 00:00:01'),
(2845, 1, 102, '0', '2000-01-01 00:00:01'),
(2846, 1, 103, '0', '2000-01-01 00:00:01'),
(2847, 1, 104, '0', '2000-01-01 00:00:01'),
(2848, 1, 105, '0', '2000-01-01 00:00:01'),
(2849, 1, 106, '0', '2000-01-01 00:00:01'),
(2850, 1, 107, '0', '2000-01-01 00:00:01'),
(2851, 1, 26, '0', '2000-01-01 00:00:01'),
(2852, 1, 108, '0', '2000-01-01 00:00:01'),
(2853, 1, 59, '0', '2000-01-01 00:00:01'),
(2854, 1, 109, '0', '2000-01-01 00:00:01'),
(2855, 1, 110, '0', '2000-01-01 00:00:01'),
(2856, 1, 38, '0', '2000-01-01 00:00:01'),
(2857, 1, 55, '0', '2000-01-01 00:00:01'),
(2858, 1, 111, '0', '2000-01-01 00:00:01'),
(2859, 1, 112, '0', '2000-01-01 00:00:01'),
(2860, 1, 113, '0', '2000-01-01 00:00:01'),
(2861, 1, 14, '0', '2000-01-01 00:00:01'),
(2862, 1, 14, '0', '2000-01-01 00:00:01'),
(2863, 1, 22, '0', '2000-01-01 00:00:01'),
(2864, 1, 23, '0', '2000-01-01 00:00:01'),
(2865, 1, 24, '0', '2000-01-01 00:00:01'),
(2866, 1, 25, '0', '2000-01-01 00:00:01'),
(2867, 1, 26, '0', '2000-01-01 00:00:01'),
(2868, 1, 27, '0', '2000-01-01 00:00:01'),
(2869, 1, 28, '0', '2000-01-01 00:00:01'),
(2870, 1, 29, '0', '2000-01-01 00:00:01'),
(2871, 1, 30, '0', '2000-01-01 00:00:01'),
(2872, 1, 31, '0', '2000-01-01 00:00:01'),
(2873, 1, 32, '0', '2000-01-01 00:00:01'),
(2874, 1, 33, '0', '2000-01-01 00:00:01'),
(2875, 1, 34, '0', '2000-01-01 00:00:01'),
(2876, 1, 35, '0', '2000-01-01 00:00:01'),
(2877, 1, 36, '0', '2000-01-01 00:00:01'),
(2878, 1, 37, '0', '2000-01-01 00:00:01'),
(2879, 1, 38, '0', '2000-01-01 00:00:01'),
(2880, 1, 39, '0', '2000-01-01 00:00:01'),
(2881, 1, 40, '0', '2000-01-01 00:00:01'),
(2882, 1, 41, '0', '2000-01-01 00:00:01'),
(2883, 1, 42, '0', '2000-01-01 00:00:01'),
(2884, 1, 43, '0', '2000-01-01 00:00:01'),
(2885, 1, 44, '0', '2000-01-01 00:00:01'),
(2886, 1, 34, '0', '2000-01-01 00:00:01'),
(2887, 1, 45, '0', '2000-01-01 00:00:01'),
(2888, 1, 46, '0', '2000-01-01 00:00:01'),
(2889, 1, 47, '0', '2000-01-01 00:00:01'),
(2890, 1, 48, '0', '2000-01-01 00:00:01'),
(2891, 1, 49, '0', '2000-01-01 00:00:01'),
(2892, 1, 50, '0', '2000-01-01 00:00:01'),
(2893, 1, 51, '0', '2000-01-01 00:00:01'),
(2894, 1, 52, '0', '2000-01-01 00:00:01'),
(2895, 1, 53, '0', '2000-01-01 00:00:01'),
(2896, 1, 54, '0', '2000-01-01 00:00:01'),
(2897, 1, 55, '0', '2000-01-01 00:00:01'),
(2898, 1, 30, '0', '2000-01-01 00:00:01'),
(2899, 1, 56, '0', '2000-01-01 00:00:01'),
(2900, 1, 57, '0', '2000-01-01 00:00:01'),
(2901, 1, 58, '0', '2000-01-01 00:00:01'),
(2902, 1, 59, '0', '2000-01-01 00:00:01'),
(2903, 1, 60, '0', '2000-01-01 00:00:01'),
(2904, 1, 61, '0', '2000-01-01 00:00:01'),
(2905, 1, 62, '0', '2000-01-01 00:00:01'),
(2906, 1, 63, '0', '2000-01-01 00:00:01'),
(2907, 1, 64, '0', '2000-01-01 00:00:01'),
(2908, 1, 65, '0', '2000-01-01 00:00:01'),
(2909, 1, 26, '0', '2000-01-01 00:00:01'),
(2910, 1, 66, '0', '2000-01-01 00:00:01'),
(2911, 1, 66, '0', '2000-01-01 00:00:01'),
(2912, 1, 5, '0', '2000-01-01 00:00:01'),
(2913, 1, 67, '0', '2000-01-01 00:00:01'),
(2914, 1, 68, '0', '2000-01-01 00:00:01'),
(2915, 1, 39, '0', '2000-01-01 00:00:01'),
(2916, 1, 69, '0', '2000-01-01 00:00:01'),
(2917, 1, 70, '0', '2000-01-01 00:00:01'),
(2918, 1, 28, '0', '2000-01-01 00:00:01'),
(2919, 1, 37, '0', '2000-01-01 00:00:01'),
(2920, 1, 71, '0', '2000-01-01 00:00:01'),
(2921, 1, 72, '0', '2000-01-01 00:00:01'),
(2922, 1, 73, '0', '2000-01-01 00:00:01'),
(2923, 1, 74, '0', '2000-01-01 00:00:01'),
(2924, 1, 75, '0', '2000-01-01 00:00:01'),
(2925, 1, 76, '0', '2000-01-01 00:00:01'),
(2926, 1, 77, '0', '2000-01-01 00:00:01'),
(2927, 1, 78, '0', '2000-01-01 00:00:01'),
(2928, 1, 79, '0', '2000-01-01 00:00:01'),
(2929, 1, 80, '0', '2000-01-01 00:00:01'),
(2930, 1, 81, '0', '2000-01-01 00:00:01'),
(2931, 1, 82, '0', '2000-01-01 00:00:01'),
(2932, 1, 83, '0', '2000-01-01 00:00:01'),
(2933, 1, 84, '0', '2000-01-01 00:00:01'),
(2934, 1, 84, '0', '2000-01-01 00:00:01'),
(2935, 1, 85, '0', '2000-01-01 00:00:01'),
(2936, 1, 86, '0', '2000-01-01 00:00:01'),
(2937, 1, 87, '0', '2000-01-01 00:00:01'),
(2938, 1, 88, '0', '2000-01-01 00:00:01'),
(2939, 1, 2, '0', '2000-01-01 00:00:01'),
(2940, 1, 89, '0', '2000-01-01 00:00:01'),
(2941, 1, 90, '0', '2000-01-01 00:00:01'),
(2942, 1, 91, '0', '2000-01-01 00:00:01'),
(2943, 1, 27, '0', '2000-01-01 00:00:01'),
(2944, 1, 92, '0', '2000-01-01 00:00:01'),
(2945, 1, 93, '0', '2000-01-01 00:00:01'),
(2946, 1, 94, '0', '2000-01-01 00:00:01'),
(2947, 1, 95, '0', '2000-01-01 00:00:01'),
(2948, 1, 48, '0', '2000-01-01 00:00:01'),
(2949, 1, 96, '0', '2000-01-01 00:00:01'),
(2950, 1, 97, '0', '2000-01-01 00:00:01'),
(2951, 1, 84, '0', '2000-01-01 00:00:01'),
(2952, 1, 98, '0', '2000-01-01 00:00:01'),
(2953, 1, 99, '0', '2000-01-01 00:00:01'),
(2954, 1, 52, '0', '2000-01-01 00:00:01'),
(2955, 1, 41, '0', '2000-01-01 00:00:01'),
(2956, 1, 100, '0', '2000-01-01 00:00:01'),
(2957, 1, 101, '0', '2000-01-01 00:00:01'),
(2958, 1, 102, '0', '2000-01-01 00:00:01'),
(2959, 1, 103, '0', '2000-01-01 00:00:01'),
(2960, 1, 104, '0', '2000-01-01 00:00:01'),
(2961, 1, 105, '0', '2000-01-01 00:00:01'),
(2962, 1, 106, '0', '2000-01-01 00:00:01'),
(2963, 1, 107, '0', '2000-01-01 00:00:01'),
(2964, 1, 26, '0', '2000-01-01 00:00:01'),
(2965, 1, 108, '0', '2000-01-01 00:00:01'),
(2966, 1, 59, '0', '2000-01-01 00:00:01'),
(2967, 1, 109, '0', '2000-01-01 00:00:01'),
(2968, 1, 110, '0', '2000-01-01 00:00:01'),
(2969, 1, 38, '0', '2000-01-01 00:00:01'),
(2970, 1, 55, '0', '2000-01-01 00:00:01'),
(2971, 1, 111, '0', '2000-01-01 00:00:01'),
(2972, 1, 112, '0', '2000-01-01 00:00:01'),
(2973, 1, 113, '0', '2000-01-01 00:00:01'),
(2974, 1, 14, '0', '2000-01-01 00:00:01'),
(2975, 1, 14, '0', '2000-01-01 00:00:01'),
(2976, 1, 22, '0', '2000-01-01 00:00:01'),
(2977, 1, 23, '0', '2000-01-01 00:00:01'),
(2978, 1, 24, '0', '2000-01-01 00:00:01'),
(2979, 1, 25, '0', '2000-01-01 00:00:01'),
(2980, 1, 26, '0', '2000-01-01 00:00:01'),
(2981, 1, 27, '0', '2000-01-01 00:00:01'),
(2982, 1, 28, '0', '2000-01-01 00:00:01'),
(2983, 1, 29, '0', '2000-01-01 00:00:01'),
(2984, 1, 30, '0', '2000-01-01 00:00:01'),
(2985, 1, 31, '0', '2000-01-01 00:00:01'),
(2986, 1, 32, '0', '2000-01-01 00:00:01'),
(2987, 1, 33, '0', '2000-01-01 00:00:01'),
(2988, 1, 34, '0', '2000-01-01 00:00:01'),
(2989, 1, 35, '0', '2000-01-01 00:00:01'),
(2990, 1, 36, '0', '2000-01-01 00:00:01'),
(2991, 1, 37, '0', '2000-01-01 00:00:01'),
(2992, 1, 38, '0', '2000-01-01 00:00:01'),
(2993, 1, 39, '0', '2000-01-01 00:00:01'),
(2994, 1, 40, '0', '2000-01-01 00:00:01'),
(2995, 1, 41, '0', '2000-01-01 00:00:01'),
(2996, 1, 42, '0', '2000-01-01 00:00:01'),
(2997, 1, 43, '0', '2000-01-01 00:00:01'),
(2998, 1, 44, '0', '2000-01-01 00:00:01'),
(2999, 1, 34, '0', '2000-01-01 00:00:01'),
(3000, 1, 45, '0', '2000-01-01 00:00:01'),
(3001, 1, 46, '0', '2000-01-01 00:00:01'),
(3002, 1, 47, '0', '2000-01-01 00:00:01'),
(3003, 1, 48, '0', '2000-01-01 00:00:01'),
(3004, 1, 49, '0', '2000-01-01 00:00:01'),
(3005, 1, 50, '0', '2000-01-01 00:00:01'),
(3006, 1, 51, '0', '2000-01-01 00:00:01'),
(3007, 1, 52, '0', '2000-01-01 00:00:01'),
(3008, 1, 53, '0', '2000-01-01 00:00:01'),
(3009, 1, 54, '0', '2000-01-01 00:00:01'),
(3010, 1, 55, '0', '2000-01-01 00:00:01'),
(3011, 1, 30, '0', '2000-01-01 00:00:01'),
(3012, 1, 56, '0', '2000-01-01 00:00:01'),
(3013, 1, 57, '0', '2000-01-01 00:00:01'),
(3014, 1, 58, '0', '2000-01-01 00:00:01'),
(3015, 1, 59, '0', '2000-01-01 00:00:01'),
(3016, 1, 60, '0', '2000-01-01 00:00:01'),
(3017, 1, 61, '0', '2000-01-01 00:00:01'),
(3018, 1, 62, '0', '2000-01-01 00:00:01'),
(3019, 1, 63, '0', '2000-01-01 00:00:01'),
(3020, 1, 64, '0', '2000-01-01 00:00:01'),
(3021, 1, 65, '0', '2000-01-01 00:00:01'),
(3022, 1, 26, '0', '2000-01-01 00:00:01'),
(3023, 1, 66, '0', '2000-01-01 00:00:01'),
(3024, 1, 66, '0', '2000-01-01 00:00:01'),
(3025, 1, 5, '0', '2000-01-01 00:00:01'),
(3026, 1, 67, '0', '2000-01-01 00:00:01'),
(3027, 1, 68, '0', '2000-01-01 00:00:01'),
(3028, 1, 39, '0', '2000-01-01 00:00:01'),
(3029, 1, 69, '0', '2000-01-01 00:00:01'),
(3030, 1, 70, '0', '2000-01-01 00:00:01'),
(3031, 1, 28, '0', '2000-01-01 00:00:01'),
(3032, 1, 37, '0', '2000-01-01 00:00:01'),
(3033, 1, 71, '0', '2000-01-01 00:00:01'),
(3034, 1, 72, '0', '2000-01-01 00:00:01'),
(3035, 1, 73, '0', '2000-01-01 00:00:01'),
(3036, 1, 74, '0', '2000-01-01 00:00:01'),
(3037, 1, 75, '0', '2000-01-01 00:00:01'),
(3038, 1, 76, '0', '2000-01-01 00:00:01'),
(3039, 1, 77, '0', '2000-01-01 00:00:01'),
(3040, 1, 78, '0', '2000-01-01 00:00:01'),
(3041, 1, 79, '0', '2000-01-01 00:00:01'),
(3042, 1, 80, '0', '2000-01-01 00:00:01'),
(3043, 1, 81, '0', '2000-01-01 00:00:01'),
(3044, 1, 82, '0', '2000-01-01 00:00:01'),
(3045, 1, 83, '0', '2000-01-01 00:00:01'),
(3046, 1, 84, '0', '2000-01-01 00:00:01'),
(3047, 1, 84, '0', '2000-01-01 00:00:01'),
(3048, 1, 85, '0', '2000-01-01 00:00:01'),
(3049, 1, 86, '0', '2000-01-01 00:00:01'),
(3050, 1, 87, '0', '2000-01-01 00:00:01'),
(3051, 1, 88, '0', '2000-01-01 00:00:01'),
(3052, 1, 2, '0', '2000-01-01 00:00:01'),
(3053, 1, 89, '0', '2000-01-01 00:00:01'),
(3054, 1, 90, '0', '2000-01-01 00:00:01'),
(3055, 1, 91, '0', '2000-01-01 00:00:01'),
(3056, 1, 27, '0', '2000-01-01 00:00:01'),
(3057, 1, 92, '0', '2000-01-01 00:00:01'),
(3058, 1, 93, '0', '2000-01-01 00:00:01'),
(3059, 1, 94, '0', '2000-01-01 00:00:01'),
(3060, 1, 95, '0', '2000-01-01 00:00:01'),
(3061, 1, 48, '0', '2000-01-01 00:00:01'),
(3062, 1, 96, '0', '2000-01-01 00:00:01'),
(3063, 1, 97, '0', '2000-01-01 00:00:01'),
(3064, 1, 84, '0', '2000-01-01 00:00:01'),
(3065, 1, 98, '0', '2000-01-01 00:00:01'),
(3066, 1, 99, '0', '2000-01-01 00:00:01'),
(3067, 1, 52, '0', '2000-01-01 00:00:01'),
(3068, 1, 41, '0', '2000-01-01 00:00:01'),
(3069, 1, 100, '0', '2000-01-01 00:00:01'),
(3070, 1, 101, '0', '2000-01-01 00:00:01'),
(3071, 1, 102, '0', '2000-01-01 00:00:01'),
(3072, 1, 103, '0', '2000-01-01 00:00:01'),
(3073, 1, 104, '0', '2000-01-01 00:00:01'),
(3074, 1, 105, '0', '2000-01-01 00:00:01'),
(3075, 1, 106, '0', '2000-01-01 00:00:01'),
(3076, 1, 107, '0', '2000-01-01 00:00:01'),
(3077, 1, 26, '0', '2000-01-01 00:00:01'),
(3078, 1, 108, '0', '2000-01-01 00:00:01'),
(3079, 1, 59, '0', '2000-01-01 00:00:01'),
(3080, 1, 109, '0', '2000-01-01 00:00:01'),
(3081, 1, 110, '0', '2000-01-01 00:00:01'),
(3082, 1, 38, '0', '2000-01-01 00:00:01'),
(3083, 1, 55, '0', '2000-01-01 00:00:01'),
(3084, 1, 111, '0', '2000-01-01 00:00:01'),
(3085, 1, 112, '0', '2000-01-01 00:00:01'),
(3086, 1, 113, '0', '2000-01-01 00:00:01'),
(3087, 1, 14, '0', '2000-01-01 00:00:01'),
(3088, 1, 14, '0', '2000-01-01 00:00:01'),
(3089, 1, 22, '0', '2000-01-01 00:00:01'),
(3090, 1, 23, '0', '2000-01-01 00:00:01'),
(3091, 1, 24, '0', '2000-01-01 00:00:01'),
(3092, 1, 25, '0', '2000-01-01 00:00:01'),
(3093, 1, 26, '0', '2000-01-01 00:00:01'),
(3094, 1, 27, '0', '2000-01-01 00:00:01'),
(3095, 1, 28, '0', '2000-01-01 00:00:01'),
(3096, 1, 29, '0', '2000-01-01 00:00:01'),
(3097, 1, 30, '0', '2000-01-01 00:00:01'),
(3098, 1, 31, '0', '2000-01-01 00:00:01'),
(3099, 1, 32, '0', '2000-01-01 00:00:01'),
(3100, 1, 33, '0', '2000-01-01 00:00:01'),
(3101, 1, 34, '0', '2000-01-01 00:00:01'),
(3102, 1, 35, '0', '2000-01-01 00:00:01'),
(3103, 1, 36, '0', '2000-01-01 00:00:01'),
(3104, 1, 37, '0', '2000-01-01 00:00:01'),
(3105, 1, 38, '0', '2000-01-01 00:00:01'),
(3106, 1, 39, '0', '2000-01-01 00:00:01'),
(3107, 1, 40, '0', '2000-01-01 00:00:01'),
(3108, 1, 41, '0', '2000-01-01 00:00:01'),
(3109, 1, 42, '0', '2000-01-01 00:00:01'),
(3110, 1, 43, '0', '2000-01-01 00:00:01'),
(3111, 1, 44, '0', '2000-01-01 00:00:01'),
(3112, 1, 34, '0', '2000-01-01 00:00:01'),
(3113, 1, 45, '0', '2000-01-01 00:00:01'),
(3114, 1, 46, '0', '2000-01-01 00:00:01'),
(3115, 1, 47, '0', '2000-01-01 00:00:01'),
(3116, 1, 48, '0', '2000-01-01 00:00:01'),
(3117, 1, 49, '0', '2000-01-01 00:00:01'),
(3118, 1, 50, '0', '2000-01-01 00:00:01'),
(3119, 1, 51, '0', '2000-01-01 00:00:01'),
(3120, 1, 52, '0', '2000-01-01 00:00:01'),
(3121, 1, 53, '0', '2000-01-01 00:00:01'),
(3122, 1, 54, '0', '2000-01-01 00:00:01'),
(3123, 1, 55, '0', '2000-01-01 00:00:01'),
(3124, 1, 30, '0', '2000-01-01 00:00:01'),
(3125, 1, 56, '0', '2000-01-01 00:00:01'),
(3126, 1, 57, '0', '2000-01-01 00:00:01'),
(3127, 1, 58, '0', '2000-01-01 00:00:01'),
(3128, 1, 59, '0', '2000-01-01 00:00:01'),
(3129, 1, 60, '0', '2000-01-01 00:00:01'),
(3130, 1, 61, '0', '2000-01-01 00:00:01'),
(3131, 1, 62, '0', '2000-01-01 00:00:01'),
(3132, 1, 63, '0', '2000-01-01 00:00:01'),
(3133, 1, 64, '0', '2000-01-01 00:00:01'),
(3134, 1, 65, '0', '2000-01-01 00:00:01'),
(3135, 1, 26, '0', '2000-01-01 00:00:01'),
(3136, 1, 66, '0', '2000-01-01 00:00:01'),
(3137, 1, 66, '0', '2000-01-01 00:00:01'),
(3138, 1, 5, '0', '2000-01-01 00:00:01'),
(3139, 1, 67, '0', '2000-01-01 00:00:01'),
(3140, 1, 68, '0', '2000-01-01 00:00:01'),
(3141, 1, 39, '0', '2000-01-01 00:00:01'),
(3142, 1, 69, '0', '2000-01-01 00:00:01'),
(3143, 1, 70, '0', '2000-01-01 00:00:01'),
(3144, 1, 28, '0', '2000-01-01 00:00:01'),
(3145, 1, 37, '0', '2000-01-01 00:00:01'),
(3146, 1, 71, '0', '2000-01-01 00:00:01'),
(3147, 1, 72, '0', '2000-01-01 00:00:01'),
(3148, 1, 73, '0', '2000-01-01 00:00:01'),
(3149, 1, 74, '0', '2000-01-01 00:00:01'),
(3150, 1, 75, '0', '2000-01-01 00:00:01'),
(3151, 1, 76, '0', '2000-01-01 00:00:01'),
(3152, 1, 77, '0', '2000-01-01 00:00:01'),
(3153, 1, 78, '0', '2000-01-01 00:00:01'),
(3154, 1, 79, '0', '2000-01-01 00:00:01'),
(3155, 1, 80, '0', '2000-01-01 00:00:01'),
(3156, 1, 81, '0', '2000-01-01 00:00:01'),
(3157, 1, 82, '0', '2000-01-01 00:00:01'),
(3158, 1, 83, '0', '2000-01-01 00:00:01'),
(3159, 1, 84, '0', '2000-01-01 00:00:01'),
(3160, 1, 84, '0', '2000-01-01 00:00:01'),
(3161, 1, 85, '0', '2000-01-01 00:00:01'),
(3162, 1, 86, '0', '2000-01-01 00:00:01'),
(3163, 1, 87, '0', '2000-01-01 00:00:01'),
(3164, 1, 88, '0', '2000-01-01 00:00:01'),
(3165, 1, 2, '0', '2000-01-01 00:00:01'),
(3166, 1, 89, '0', '2000-01-01 00:00:01'),
(3167, 1, 90, '0', '2000-01-01 00:00:01'),
(3168, 1, 91, '0', '2000-01-01 00:00:01'),
(3169, 1, 27, '0', '2000-01-01 00:00:01'),
(3170, 1, 92, '0', '2000-01-01 00:00:01'),
(3171, 1, 93, '0', '2000-01-01 00:00:01'),
(3172, 1, 94, '0', '2000-01-01 00:00:01'),
(3173, 1, 95, '0', '2000-01-01 00:00:01'),
(3174, 1, 48, '0', '2000-01-01 00:00:01'),
(3175, 1, 96, '0', '2000-01-01 00:00:01'),
(3176, 1, 97, '0', '2000-01-01 00:00:01'),
(3177, 1, 84, '0', '2000-01-01 00:00:01'),
(3178, 1, 98, '0', '2000-01-01 00:00:01'),
(3179, 1, 99, '0', '2000-01-01 00:00:01'),
(3180, 1, 52, '0', '2000-01-01 00:00:01'),
(3181, 1, 41, '0', '2000-01-01 00:00:01'),
(3182, 1, 100, '0', '2000-01-01 00:00:01'),
(3183, 1, 101, '0', '2000-01-01 00:00:01'),
(3184, 1, 102, '0', '2000-01-01 00:00:01'),
(3185, 1, 103, '0', '2000-01-01 00:00:01'),
(3186, 1, 104, '0', '2000-01-01 00:00:01'),
(3187, 1, 105, '0', '2000-01-01 00:00:01'),
(3188, 1, 106, '0', '2000-01-01 00:00:01'),
(3189, 1, 107, '0', '2000-01-01 00:00:01'),
(3190, 1, 26, '0', '2000-01-01 00:00:01'),
(3191, 1, 108, '0', '2000-01-01 00:00:01'),
(3192, 1, 59, '0', '2000-01-01 00:00:01'),
(3193, 1, 109, '0', '2000-01-01 00:00:01'),
(3194, 1, 110, '0', '2000-01-01 00:00:01'),
(3195, 1, 38, '0', '2000-01-01 00:00:01'),
(3196, 1, 55, '0', '2000-01-01 00:00:01'),
(3197, 1, 111, '0', '2000-01-01 00:00:01'),
(3198, 1, 112, '0', '2000-01-01 00:00:01'),
(3199, 1, 113, '0', '2000-01-01 00:00:01'),
(3200, 1, 14, '0', '2000-01-01 00:00:01'),
(3201, 1, 14, '0', '2000-01-01 00:00:01'),
(3202, 1, 22, '0', '2000-01-01 00:00:01'),
(3203, 1, 23, '0', '2000-01-01 00:00:01'),
(3204, 1, 24, '0', '2000-01-01 00:00:01'),
(3205, 1, 25, '0', '2000-01-01 00:00:01'),
(3206, 1, 26, '0', '2000-01-01 00:00:01'),
(3207, 1, 27, '0', '2000-01-01 00:00:01'),
(3208, 1, 28, '0', '2000-01-01 00:00:01'),
(3209, 1, 29, '0', '2000-01-01 00:00:01'),
(3210, 1, 30, '0', '2000-01-01 00:00:01'),
(3211, 1, 31, '0', '2000-01-01 00:00:01'),
(3212, 1, 32, '0', '2000-01-01 00:00:01'),
(3213, 1, 33, '0', '2000-01-01 00:00:01'),
(3214, 1, 34, '0', '2000-01-01 00:00:01'),
(3215, 1, 35, '0', '2000-01-01 00:00:01'),
(3216, 1, 36, '0', '2000-01-01 00:00:01'),
(3217, 1, 37, '0', '2000-01-01 00:00:01'),
(3218, 1, 38, '0', '2000-01-01 00:00:01'),
(3219, 1, 39, '0', '2000-01-01 00:00:01'),
(3220, 1, 40, '0', '2000-01-01 00:00:01'),
(3221, 1, 41, '0', '2000-01-01 00:00:01'),
(3222, 1, 42, '0', '2000-01-01 00:00:01'),
(3223, 1, 43, '0', '2000-01-01 00:00:01'),
(3224, 1, 44, '0', '2000-01-01 00:00:01'),
(3225, 1, 34, '0', '2000-01-01 00:00:01'),
(3226, 1, 45, '0', '2000-01-01 00:00:01'),
(3227, 1, 46, '0', '2000-01-01 00:00:01'),
(3228, 1, 47, '0', '2000-01-01 00:00:01'),
(3229, 1, 48, '0', '2000-01-01 00:00:01'),
(3230, 1, 49, '0', '2000-01-01 00:00:01'),
(3231, 1, 50, '0', '2000-01-01 00:00:01'),
(3232, 1, 51, '0', '2000-01-01 00:00:01'),
(3233, 1, 52, '0', '2000-01-01 00:00:01'),
(3234, 1, 53, '0', '2000-01-01 00:00:01'),
(3235, 1, 54, '0', '2000-01-01 00:00:01'),
(3236, 1, 55, '0', '2000-01-01 00:00:01'),
(3237, 1, 30, '0', '2000-01-01 00:00:01'),
(3238, 1, 56, '0', '2000-01-01 00:00:01'),
(3239, 1, 57, '0', '2000-01-01 00:00:01'),
(3240, 1, 58, '0', '2000-01-01 00:00:01'),
(3241, 1, 59, '0', '2000-01-01 00:00:01'),
(3242, 1, 60, '0', '2000-01-01 00:00:01'),
(3243, 1, 61, '0', '2000-01-01 00:00:01'),
(3244, 1, 62, '0', '2000-01-01 00:00:01'),
(3245, 1, 63, '0', '2000-01-01 00:00:01'),
(3246, 1, 64, '0', '2000-01-01 00:00:01'),
(3247, 1, 65, '0', '2000-01-01 00:00:01'),
(3248, 1, 26, '0', '2000-01-01 00:00:01'),
(3249, 1, 66, '0', '2000-01-01 00:00:01'),
(3250, 1, 66, '0', '2000-01-01 00:00:01'),
(3251, 1, 5, '0', '2000-01-01 00:00:01'),
(3252, 1, 67, '0', '2000-01-01 00:00:01'),
(3253, 1, 68, '0', '2000-01-01 00:00:01'),
(3254, 1, 39, '0', '2000-01-01 00:00:01'),
(3255, 1, 69, '0', '2000-01-01 00:00:01'),
(3256, 1, 70, '0', '2000-01-01 00:00:01'),
(3257, 1, 28, '0', '2000-01-01 00:00:01'),
(3258, 1, 37, '0', '2000-01-01 00:00:01'),
(3259, 1, 71, '0', '2000-01-01 00:00:01'),
(3260, 1, 72, '0', '2000-01-01 00:00:01'),
(3261, 1, 73, '0', '2000-01-01 00:00:01'),
(3262, 1, 74, '0', '2000-01-01 00:00:01'),
(3263, 1, 75, '0', '2000-01-01 00:00:01'),
(3264, 1, 76, '0', '2000-01-01 00:00:01'),
(3265, 1, 77, '0', '2000-01-01 00:00:01'),
(3266, 1, 78, '0', '2000-01-01 00:00:01'),
(3267, 1, 79, '0', '2000-01-01 00:00:01'),
(3268, 1, 80, '0', '2000-01-01 00:00:01'),
(3269, 1, 81, '0', '2000-01-01 00:00:01'),
(3270, 1, 82, '0', '2000-01-01 00:00:01'),
(3271, 1, 83, '0', '2000-01-01 00:00:01'),
(3272, 1, 84, '0', '2000-01-01 00:00:01'),
(3273, 1, 84, '0', '2000-01-01 00:00:01'),
(3274, 1, 85, '0', '2000-01-01 00:00:01'),
(3275, 1, 86, '0', '2000-01-01 00:00:01'),
(3276, 1, 87, '0', '2000-01-01 00:00:01'),
(3277, 1, 88, '0', '2000-01-01 00:00:01'),
(3278, 1, 2, '0', '2000-01-01 00:00:01'),
(3279, 1, 89, '0', '2000-01-01 00:00:01'),
(3280, 1, 90, '0', '2000-01-01 00:00:01'),
(3281, 1, 91, '0', '2000-01-01 00:00:01'),
(3282, 1, 27, '0', '2000-01-01 00:00:01'),
(3283, 1, 92, '0', '2000-01-01 00:00:01'),
(3284, 1, 93, '0', '2000-01-01 00:00:01'),
(3285, 1, 94, '0', '2000-01-01 00:00:01'),
(3286, 1, 95, '0', '2000-01-01 00:00:01'),
(3287, 1, 48, '0', '2000-01-01 00:00:01'),
(3288, 1, 96, '0', '2000-01-01 00:00:01'),
(3289, 1, 97, '0', '2000-01-01 00:00:01'),
(3290, 1, 84, '0', '2000-01-01 00:00:01'),
(3291, 1, 98, '0', '2000-01-01 00:00:01'),
(3292, 1, 99, '0', '2000-01-01 00:00:01'),
(3293, 1, 52, '0', '2000-01-01 00:00:01'),
(3294, 1, 41, '0', '2000-01-01 00:00:01'),
(3295, 1, 100, '0', '2000-01-01 00:00:01'),
(3296, 1, 101, '0', '2000-01-01 00:00:01'),
(3297, 1, 102, '0', '2000-01-01 00:00:01'),
(3298, 1, 103, '0', '2000-01-01 00:00:01'),
(3299, 1, 104, '0', '2000-01-01 00:00:01'),
(3300, 1, 105, '0', '2000-01-01 00:00:01'),
(3301, 1, 106, '0', '2000-01-01 00:00:01'),
(3302, 1, 107, '0', '2000-01-01 00:00:01'),
(3303, 1, 26, '0', '2000-01-01 00:00:01'),
(3304, 1, 108, '0', '2000-01-01 00:00:01'),
(3305, 1, 59, '0', '2000-01-01 00:00:01'),
(3306, 1, 109, '0', '2000-01-01 00:00:01'),
(3307, 1, 110, '0', '2000-01-01 00:00:01'),
(3308, 1, 38, '0', '2000-01-01 00:00:01'),
(3309, 1, 55, '0', '2000-01-01 00:00:01'),
(3310, 1, 111, '0', '2000-01-01 00:00:01'),
(3311, 1, 112, '0', '2000-01-01 00:00:01'),
(3312, 1, 113, '0', '2000-01-01 00:00:01'),
(3313, 1, 14, '0', '2000-01-01 00:00:01'),
(3314, 1, 14, '0', '2000-01-01 00:00:01'),
(3315, 1, 22, '0', '2000-01-01 00:00:01'),
(3316, 1, 23, '0', '2000-01-01 00:00:01'),
(3317, 1, 24, '0', '2000-01-01 00:00:01'),
(3318, 1, 25, '0', '2000-01-01 00:00:01'),
(3319, 1, 26, '0', '2000-01-01 00:00:01'),
(3320, 1, 27, '0', '2000-01-01 00:00:01'),
(3321, 1, 28, '0', '2000-01-01 00:00:01'),
(3322, 1, 29, '0', '2000-01-01 00:00:01'),
(3323, 1, 30, '0', '2000-01-01 00:00:01'),
(3324, 1, 31, '0', '2000-01-01 00:00:01'),
(3325, 1, 32, '0', '2000-01-01 00:00:01'),
(3326, 1, 33, '0', '2000-01-01 00:00:01'),
(3327, 1, 34, '0', '2000-01-01 00:00:01'),
(3328, 1, 35, '0', '2000-01-01 00:00:01'),
(3329, 1, 36, '0', '2000-01-01 00:00:01'),
(3330, 1, 37, '0', '2000-01-01 00:00:01'),
(3331, 1, 38, '0', '2000-01-01 00:00:01'),
(3332, 1, 39, '0', '2000-01-01 00:00:01'),
(3333, 1, 40, '0', '2000-01-01 00:00:01'),
(3334, 1, 41, '0', '2000-01-01 00:00:01'),
(3335, 1, 42, '0', '2000-01-01 00:00:01'),
(3336, 1, 43, '0', '2000-01-01 00:00:01'),
(3337, 1, 44, '0', '2000-01-01 00:00:01'),
(3338, 1, 34, '0', '2000-01-01 00:00:01'),
(3339, 1, 45, '0', '2000-01-01 00:00:01'),
(3340, 1, 46, '0', '2000-01-01 00:00:01'),
(3341, 1, 47, '0', '2000-01-01 00:00:01'),
(3342, 1, 48, '0', '2000-01-01 00:00:01'),
(3343, 1, 49, '0', '2000-01-01 00:00:01'),
(3344, 1, 50, '0', '2000-01-01 00:00:01'),
(3345, 1, 51, '0', '2000-01-01 00:00:01'),
(3346, 1, 52, '0', '2000-01-01 00:00:01'),
(3347, 1, 53, '0', '2000-01-01 00:00:01'),
(3348, 1, 54, '0', '2000-01-01 00:00:01'),
(3349, 1, 55, '0', '2000-01-01 00:00:01'),
(3350, 1, 30, '0', '2000-01-01 00:00:01'),
(3351, 1, 56, '0', '2000-01-01 00:00:01'),
(3352, 1, 57, '0', '2000-01-01 00:00:01'),
(3353, 1, 58, '0', '2000-01-01 00:00:01'),
(3354, 1, 59, '0', '2000-01-01 00:00:01'),
(3355, 1, 60, '0', '2000-01-01 00:00:01'),
(3356, 1, 61, '0', '2000-01-01 00:00:01'),
(3357, 1, 62, '0', '2000-01-01 00:00:01'),
(3358, 1, 63, '0', '2000-01-01 00:00:01'),
(3359, 1, 64, '0', '2000-01-01 00:00:01'),
(3360, 1, 65, '0', '2000-01-01 00:00:01'),
(3361, 1, 26, '0', '2000-01-01 00:00:01'),
(3362, 1, 66, '0', '2000-01-01 00:00:01'),
(3363, 1, 66, '0', '2000-01-01 00:00:01'),
(3364, 1, 5, '0', '2000-01-01 00:00:01'),
(3365, 1, 67, '0', '2000-01-01 00:00:01'),
(3366, 1, 68, '0', '2000-01-01 00:00:01'),
(3367, 1, 39, '0', '2000-01-01 00:00:01'),
(3368, 1, 69, '0', '2000-01-01 00:00:01'),
(3369, 1, 70, '0', '2000-01-01 00:00:01'),
(3370, 1, 28, '0', '2000-01-01 00:00:01'),
(3371, 1, 37, '0', '2000-01-01 00:00:01'),
(3372, 1, 71, '0', '2000-01-01 00:00:01'),
(3373, 1, 72, '0', '2000-01-01 00:00:01'),
(3374, 1, 73, '0', '2000-01-01 00:00:01'),
(3375, 1, 74, '0', '2000-01-01 00:00:01'),
(3376, 1, 75, '0', '2000-01-01 00:00:01'),
(3377, 1, 76, '0', '2000-01-01 00:00:01'),
(3378, 1, 77, '0', '2000-01-01 00:00:01'),
(3379, 1, 78, '0', '2000-01-01 00:00:01'),
(3380, 1, 79, '0', '2000-01-01 00:00:01'),
(3381, 1, 80, '0', '2000-01-01 00:00:01'),
(3382, 1, 81, '0', '2000-01-01 00:00:01'),
(3383, 1, 82, '0', '2000-01-01 00:00:01'),
(3384, 1, 83, '0', '2000-01-01 00:00:01'),
(3385, 1, 84, '0', '2000-01-01 00:00:01'),
(3386, 1, 84, '0', '2000-01-01 00:00:01'),
(3387, 1, 85, '0', '2000-01-01 00:00:01'),
(3388, 1, 86, '0', '2000-01-01 00:00:01'),
(3389, 1, 87, '0', '2000-01-01 00:00:01'),
(3390, 1, 88, '0', '2000-01-01 00:00:01'),
(3391, 1, 2, '0', '2000-01-01 00:00:01'),
(3392, 1, 89, '0', '2000-01-01 00:00:01'),
(3393, 1, 90, '0', '2000-01-01 00:00:01'),
(3394, 1, 91, '0', '2000-01-01 00:00:01'),
(3395, 1, 27, '0', '2000-01-01 00:00:01'),
(3396, 1, 92, '0', '2000-01-01 00:00:01'),
(3397, 1, 93, '0', '2000-01-01 00:00:01'),
(3398, 1, 94, '0', '2000-01-01 00:00:01'),
(3399, 1, 95, '0', '2000-01-01 00:00:01'),
(3400, 1, 48, '0', '2000-01-01 00:00:01'),
(3401, 1, 96, '0', '2000-01-01 00:00:01'),
(3402, 1, 97, '0', '2000-01-01 00:00:01'),
(3403, 1, 84, '0', '2000-01-01 00:00:01'),
(3404, 1, 98, '0', '2000-01-01 00:00:01'),
(3405, 1, 99, '0', '2000-01-01 00:00:01'),
(3406, 1, 52, '0', '2000-01-01 00:00:01'),
(3407, 1, 41, '0', '2000-01-01 00:00:01'),
(3408, 1, 100, '0', '2000-01-01 00:00:01'),
(3409, 1, 101, '0', '2000-01-01 00:00:01'),
(3410, 1, 102, '0', '2000-01-01 00:00:01'),
(3411, 1, 103, '0', '2000-01-01 00:00:01'),
(3412, 1, 104, '0', '2000-01-01 00:00:01'),
(3413, 1, 105, '0', '2000-01-01 00:00:01'),
(3414, 1, 106, '0', '2000-01-01 00:00:01'),
(3415, 1, 107, '0', '2000-01-01 00:00:01'),
(3416, 1, 26, '0', '2000-01-01 00:00:01'),
(3417, 1, 108, '0', '2000-01-01 00:00:01'),
(3418, 1, 59, '0', '2000-01-01 00:00:01'),
(3419, 1, 109, '0', '2000-01-01 00:00:01'),
(3420, 1, 110, '0', '2000-01-01 00:00:01'),
(3421, 1, 38, '0', '2000-01-01 00:00:01'),
(3422, 1, 55, '0', '2000-01-01 00:00:01'),
(3423, 1, 111, '0', '2000-01-01 00:00:01'),
(3424, 1, 112, '0', '2000-01-01 00:00:01'),
(3425, 1, 113, '0', '2000-01-01 00:00:01'),
(3426, 1, 14, '0', '2000-01-01 00:00:01'),
(3427, 1, 14, '0', '2000-01-01 00:00:01'),
(3428, 1, 22, '0', '2000-01-01 00:00:01'),
(3429, 1, 23, '0', '2000-01-01 00:00:01'),
(3430, 1, 24, '0', '2000-01-01 00:00:01'),
(3431, 1, 25, '0', '2000-01-01 00:00:01'),
(3432, 1, 26, '0', '2000-01-01 00:00:01'),
(3433, 1, 27, '0', '2000-01-01 00:00:01'),
(3434, 1, 28, '0', '2000-01-01 00:00:01'),
(3435, 1, 29, '0', '2000-01-01 00:00:01'),
(3436, 1, 30, '0', '2000-01-01 00:00:01'),
(3437, 1, 31, '0', '2000-01-01 00:00:01'),
(3438, 1, 32, '0', '2000-01-01 00:00:01'),
(3439, 1, 33, '0', '2000-01-01 00:00:01'),
(3440, 1, 34, '0', '2000-01-01 00:00:01'),
(3441, 1, 35, '0', '2000-01-01 00:00:01'),
(3442, 1, 36, '0', '2000-01-01 00:00:01'),
(3443, 1, 37, '0', '2000-01-01 00:00:01'),
(3444, 1, 38, '0', '2000-01-01 00:00:01'),
(3445, 1, 39, '0', '2000-01-01 00:00:01'),
(3446, 1, 40, '0', '2000-01-01 00:00:01'),
(3447, 1, 41, '0', '2000-01-01 00:00:01'),
(3448, 1, 42, '0', '2000-01-01 00:00:01'),
(3449, 1, 43, '0', '2000-01-01 00:00:01'),
(3450, 1, 44, '0', '2000-01-01 00:00:01'),
(3451, 1, 34, '0', '2000-01-01 00:00:01'),
(3452, 1, 45, '0', '2000-01-01 00:00:01'),
(3453, 1, 46, '0', '2000-01-01 00:00:01'),
(3454, 1, 47, '0', '2000-01-01 00:00:01'),
(3455, 1, 48, '0', '2000-01-01 00:00:01'),
(3456, 1, 49, '0', '2000-01-01 00:00:01'),
(3457, 1, 50, '0', '2000-01-01 00:00:01'),
(3458, 1, 51, '0', '2000-01-01 00:00:01'),
(3459, 1, 52, '0', '2000-01-01 00:00:01'),
(3460, 1, 53, '0', '2000-01-01 00:00:01'),
(3461, 1, 54, '0', '2000-01-01 00:00:01'),
(3462, 1, 55, '0', '2000-01-01 00:00:01'),
(3463, 1, 30, '0', '2000-01-01 00:00:01'),
(3464, 1, 56, '0', '2000-01-01 00:00:01'),
(3465, 1, 57, '0', '2000-01-01 00:00:01'),
(3466, 1, 58, '0', '2000-01-01 00:00:01'),
(3467, 1, 59, '0', '2000-01-01 00:00:01'),
(3468, 1, 60, '0', '2000-01-01 00:00:01'),
(3469, 1, 61, '0', '2000-01-01 00:00:01'),
(3470, 1, 62, '0', '2000-01-01 00:00:01'),
(3471, 1, 63, '0', '2000-01-01 00:00:01'),
(3472, 1, 64, '0', '2000-01-01 00:00:01'),
(3473, 1, 65, '0', '2000-01-01 00:00:01'),
(3474, 1, 26, '0', '2000-01-01 00:00:01');
INSERT INTO `hoja_asistencia` (`id_hoja_asistencia`, `id_asamblea`, `id_auth_user`, `estado`, `hora`) VALUES
(3475, 1, 66, '0', '2000-01-01 00:00:01'),
(3476, 1, 66, '0', '2000-01-01 00:00:01'),
(3477, 1, 5, '0', '2000-01-01 00:00:01'),
(3478, 1, 67, '0', '2000-01-01 00:00:01'),
(3479, 1, 68, '0', '2000-01-01 00:00:01'),
(3480, 1, 39, '0', '2000-01-01 00:00:01'),
(3481, 1, 69, '0', '2000-01-01 00:00:01'),
(3482, 1, 70, '0', '2000-01-01 00:00:01'),
(3483, 1, 28, '0', '2000-01-01 00:00:01'),
(3484, 1, 37, '0', '2000-01-01 00:00:01'),
(3485, 1, 71, '0', '2000-01-01 00:00:01'),
(3486, 1, 72, '0', '2000-01-01 00:00:01'),
(3487, 1, 73, '0', '2000-01-01 00:00:01'),
(3488, 1, 74, '0', '2000-01-01 00:00:01'),
(3489, 1, 75, '0', '2000-01-01 00:00:01'),
(3490, 1, 76, '0', '2000-01-01 00:00:01'),
(3491, 1, 77, '0', '2000-01-01 00:00:01'),
(3492, 1, 78, '0', '2000-01-01 00:00:01'),
(3493, 1, 79, '0', '2000-01-01 00:00:01'),
(3494, 1, 80, '0', '2000-01-01 00:00:01'),
(3495, 1, 81, '0', '2000-01-01 00:00:01'),
(3496, 1, 82, '0', '2000-01-01 00:00:01'),
(3497, 1, 83, '0', '2000-01-01 00:00:01'),
(3498, 1, 84, '0', '2000-01-01 00:00:01'),
(3499, 1, 84, '0', '2000-01-01 00:00:01'),
(3500, 1, 85, '0', '2000-01-01 00:00:01'),
(3501, 1, 86, '0', '2000-01-01 00:00:01'),
(3502, 1, 87, '0', '2000-01-01 00:00:01'),
(3503, 1, 88, '0', '2000-01-01 00:00:01'),
(3504, 1, 2, '0', '2000-01-01 00:00:01'),
(3505, 1, 89, '0', '2000-01-01 00:00:01'),
(3506, 1, 90, '0', '2000-01-01 00:00:01'),
(3507, 1, 91, '0', '2000-01-01 00:00:01'),
(3508, 1, 27, '0', '2000-01-01 00:00:01'),
(3509, 1, 92, '0', '2000-01-01 00:00:01'),
(3510, 1, 93, '0', '2000-01-01 00:00:01'),
(3511, 1, 94, '0', '2000-01-01 00:00:01'),
(3512, 1, 95, '0', '2000-01-01 00:00:01'),
(3513, 1, 48, '0', '2000-01-01 00:00:01'),
(3514, 1, 96, '0', '2000-01-01 00:00:01'),
(3515, 1, 97, '0', '2000-01-01 00:00:01'),
(3516, 1, 84, '0', '2000-01-01 00:00:01'),
(3517, 1, 98, '0', '2000-01-01 00:00:01'),
(3518, 1, 99, '0', '2000-01-01 00:00:01'),
(3519, 1, 52, '0', '2000-01-01 00:00:01'),
(3520, 1, 41, '0', '2000-01-01 00:00:01'),
(3521, 1, 100, '0', '2000-01-01 00:00:01'),
(3522, 1, 101, '0', '2000-01-01 00:00:01'),
(3523, 1, 102, '0', '2000-01-01 00:00:01'),
(3524, 1, 103, '0', '2000-01-01 00:00:01'),
(3525, 1, 104, '0', '2000-01-01 00:00:01'),
(3526, 1, 105, '0', '2000-01-01 00:00:01'),
(3527, 1, 106, '0', '2000-01-01 00:00:01'),
(3528, 1, 107, '0', '2000-01-01 00:00:01'),
(3529, 1, 26, '0', '2000-01-01 00:00:01'),
(3530, 1, 108, '0', '2000-01-01 00:00:01'),
(3531, 1, 59, '0', '2000-01-01 00:00:01'),
(3532, 1, 109, '0', '2000-01-01 00:00:01'),
(3533, 1, 110, '0', '2000-01-01 00:00:01'),
(3534, 1, 38, '0', '2000-01-01 00:00:01'),
(3535, 1, 55, '0', '2000-01-01 00:00:01'),
(3536, 1, 111, '0', '2000-01-01 00:00:01'),
(3537, 1, 112, '0', '2000-01-01 00:00:01'),
(3538, 1, 113, '0', '2000-01-01 00:00:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `limpieza`
--

CREATE TABLE `limpieza` (
  `id_limpieza` int(11) NOT NULL,
  `decripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `fecha_limpieza` date DEFAULT NULL,
  `fecha_revision` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista`
--

CREATE TABLE `lista` (
  `id_lista` int(11) NOT NULL,
  `id_comite` int(11) DEFAULT NULL,
  `nombre_lista` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `estado` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_termino` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa`
--

CREATE TABLE `multa` (
  `id_multa` int(11) NOT NULL,
  `concepto` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `estado` varchar(10) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_asistencia`
--

CREATE TABLE `multa_asistencia` (
  `id_multa_asistencia` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL,
  `id_hoja_asistencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_limpia`
--

CREATE TABLE `multa_limpia` (
  `id_multa_limpia` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL,
  `id_det_limpia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_orden`
--

CREATE TABLE `multa_orden` (
  `id_multa_orden` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticia`
--

CREATE TABLE `noticia` (
  `id_noticia` int(11) NOT NULL,
  `titular` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(400) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `noticia`
--

INSERT INTO `noticia` (`id_noticia`, `titular`, `descripcion`, `fecha`, `foto`) VALUES
(1, 'Titulación Gratuita', 'La ONG Sedepas Norte brindará una campaña de titulación gratuita para toso los usuarios del comité de regantes Nuevo Horizonte', '2018-10-24 00:00:00', 'photos/img006.jpg'),
(2, 'Tía Nilda', 'La sra Nilda Barrios donará un puente en el Ramal 3', '2018-10-28 00:00:00', 'photos/1.PNG'),
(3, 'aaaa', 'ccc', '2019-06-15 00:00:00', 'photos/20180511_211637.jpg');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `obra`
--

CREATE TABLE `obra` (
  `id_obra` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `decripcion` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `monto` double DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_riego`
--

CREATE TABLE `orden_riego` (
  `id_orden_riego` int(11) NOT NULL,
  `id_reparto` int(11) DEFAULT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `fecha_establecida` date DEFAULT NULL,
  `fecha_inicio` datetime DEFAULT NULL,
  `duracion` double DEFAULT NULL,
  `unidad` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `cantidad_has` double DEFAULT NULL,
  `importe` double DEFAULT NULL,
  `estado` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `id_comprobante` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `orden_riego`
--

INSERT INTO `orden_riego` (`id_orden_riego`, `id_reparto`, `id_parcela`, `fecha_establecida`, `fecha_inicio`, `duracion`, `unidad`, `cantidad_has`, `importe`, `estado`, `id_comprobante`) VALUES
(5, 4, 25, '2018-12-11', '2018-12-11 02:02:00', 1.5, 'h', 1, 3.75, 'Aprobada', NULL),
(6, 4, 24, '2018-11-05', '2018-11-05 01:01:00', 2.5, 'h', 2.5, 6.25, 'Solicitada', NULL),
(7, 4, 36, '2018-12-04', '2018-12-04 04:31:00', 1.5, 'h', 1.5, 3.75, 'Rechazada', NULL),
(8, 4, 23, '2018-11-06', '2018-11-06 01:01:00', 2.5, 'h', 2.5, 6.25, 'Rechazada', NULL),
(9, 4, 82, '2019-04-22', '2019-04-22 19:05:00', 1.5, 'h', 1.5, 3.75, 'Aprobada', NULL),
(10, 4, 55, '2019-04-22', '2019-04-22 17:20:00', 2, 'h', 2, 5, 'Aprobada', NULL),
(11, 11, 42, '2018-11-24', '2018-11-15 02:17:00', 12, 'h', 12, 30, 'Solicitada', NULL),
(12, 10, 31, '2018-12-04', '2018-12-04 16:46:00', 12, 'h', 12, 30, 'Aprobada', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `parcela`
--

CREATE TABLE `parcela` (
  `id_parcela` int(11) NOT NULL,
  `nombre` varchar(60) COLLATE hp8_bin DEFAULT NULL,
  `ubicacion` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `num_toma` int(11) DEFAULT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL,
  `total_has` double DEFAULT NULL,
  `has_sembradas` double DEFAULT NULL,
  `descripcion` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `codigo_predio` varchar(25) COLLATE hp8_bin NOT NULL,
  `volumen_agua` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `parcela`
--

INSERT INTO `parcela` (`id_parcela`, `nombre`, `ubicacion`, `num_toma`, `id_canal`, `id_auth_user`, `total_has`, `has_sembradas`, `descripcion`, `estado`, `codigo_predio`, `volumen_agua`) VALUES
(4, 'Ramoncito A', '1° del canal madre', 1, 2, 14, 0.54, 0.54, 'Siembra de alfalfa', 'Activa', 'JU-NH-DII/G1:001', 2484),
(5, 'Ramoncito B', NULL, 2, 2, 14, 0.44, 0.44, NULL, 'Activa', 'JU-NH-DII/G1:002', 2024),
(6, 'Los Julios', NULL, 3, 2, 22, 3.66, 1, NULL, 'Activa', 'JU-NH-DII/G1:003', 4600),
(7, 'El Guabo', NULL, 4, 2, 23, 1.75, 1, NULL, 'Activa', 'JU-NH-DII/G1:004', 4600),
(8, 'El Puente', NULL, 5, 2, 24, 1.24, 1, NULL, 'Activa', 'JU-NH-DII/G1:005', 4600),
(9, 'Los Jardines', NULL, 6, 3, 25, 2.11, 1, NULL, 'Activa', 'JU-NH-DII/G1:006', 4600),
(10, 'El Pozo', NULL, 7, 3, 26, 0.92, 0.92, NULL, 'Activa', 'JU-NH-DII/G1:007', 4232),
(11, 'Naranja', NULL, 8, 4, 27, 1.32, 1.32, NULL, 'Activa', 'JU-NH-DII/G1:008', 6072),
(12, 'la 63', NULL, 9, 4, 28, 0.99, 0.99, NULL, 'Activa', 'JU-NH-DII/G1:009', 4554),
(13, 'Chilo', NULL, 10, 5, 29, 0.87, 0.87, NULL, 'Activa', 'JU-NH-DII/G1:010', 4094),
(14, 'la 61', NULL, 11, 2, 30, 0.68, 0.68, NULL, 'Activa', 'JU-NH-DII/G1:011', 3128),
(15, 'El Eucalipto', NULL, 12, 2, 31, 2.63, 1, NULL, 'Activa', 'JU-NH-DII/G1:012', 4600),
(16, 'El Limón', NULL, 13, 2, 32, 2.44, 2, NULL, 'Activa', 'JU-NH-DII/G1:013', 9200),
(17, 'El Pozo', NULL, 14, 2, 33, 0.81, 0.81, NULL, 'Activa', 'JU-NH-DII/G1:014', 3726),
(18, 'Ana Myle 3', NULL, 15, 2, 34, 0.99, 0.99, NULL, 'Activa', 'JU-NH-DII/G1:015', 4554),
(19, 'Alexandra', NULL, 16, 2, 35, 0.98, 0.98, NULL, 'Activa', 'JU-NH-DII/G1:016', 4508),
(20, 'El Huerto', NULL, 17, 2, 36, 1.03, 1.03, NULL, 'Activa', 'JU-NH-DII/G1:017', 4738),
(21, 'Soledad', NULL, 18, 2, 37, 1.05, 1.05, NULL, 'Activa', 'JU-NH-DII/G1:018', 4830),
(22, 'La Huerta', NULL, 19, 2, 38, 0.99, 0.99, NULL, 'Activa', 'JU-NH-DII/G1:019', 4554),
(23, 'El Algarrobo', NULL, 20, 2, 39, 0.86, 0.86, NULL, 'Activa', 'JU-NH-DII/G1:020', 3956),
(24, 'El Pino', NULL, 21, 2, 40, 1.01, 1.01, NULL, 'Activa', 'JU-NH-DII/G1:021', 4646),
(25, 'Matias', NULL, 22, 2, 41, 1.94, 1.94, NULL, 'Activa', 'JU-NH-DII/G1:022', 8924),
(26, 'El Limón', NULL, 23, 2, 42, 0.96, 0.96, NULL, 'Activa', 'JU-NH-DII/G1:023', 4416),
(27, 'La Maracuyá', NULL, 24, 2, 43, 0.94, 0.94, NULL, 'Activa', 'JU-NH-DII/G1:024', 4324),
(28, 'La Tranca', NULL, 25, 2, 44, 1.02, 1.02, NULL, 'Activa', 'JU-NH-DII/G1:0', 4692),
(29, 'Ana Myle 2', NULL, 26, 2, 34, 0.98, 0.98, NULL, 'Activa', 'JU-NH-DII/G1:026', 4094),
(30, 'Los Huabitos', NULL, 27, 2, 45, 2.58, 1.5, NULL, 'Activa', 'JU-NH-DII/G1:027', 6900),
(31, 'La Maracuyá', NULL, 28, 2, 46, 0.97, 0.97, NULL, 'Activa', 'JU-NH-DII/G1:028', 4462),
(32, 'El Guabo', NULL, 29, 2, 47, 1.15, 1.15, NULL, 'Activa', 'JU-NH-DII/G1:029', 5290),
(33, 'La Tía Fela', NULL, 30, 2, 48, 1.17, 1.17, NULL, 'Activa', 'JU-NH-DII/G1:030', 5382),
(34, 'El Letrero', NULL, 31, 2, 49, 0.6, 0.6, NULL, 'Activa', 'JU-NH-DII/G1:031', 2760),
(35, 'Las Vegas', NULL, 32, 2, 50, 1.27, 1.27, NULL, 'Activa', 'JU-NH-DII/G1:032', 5842),
(36, 'Los Plátanos', NULL, 33, 2, 51, 0.94, 0.94, NULL, 'Activa', 'JU-NH-DII/G1:033', 4324),
(37, 'El Milagro', NULL, 1, 3, 52, 1, 1, NULL, 'Activa', 'JU-NH-DII/G2:001', 4600),
(38, 'La 28', NULL, 2, 3, 53, 1.25, 1.25, NULL, 'Activa', 'JU-NH-DII/G2:002', 5750),
(39, 'Parcela N° 25', NULL, 3, 3, 54, 2.04, 2.04, NULL, 'Activa', 'JU-NH-DII/G2:003', 9384),
(40, 'La Chirimoya', NULL, 4, 3, 55, 1.24, 1.24, NULL, 'Activa', 'JU-NH-DII/G2:004', 5704),
(41, 'El Limón', NULL, 5, 3, 30, 1.95, 1.95, NULL, 'Activa', 'JU-NH-DII/G2:005', 8970),
(42, 'El Molino', NULL, 6, 3, 56, 3.19, 3.19, NULL, 'Activa', 'JU-NH-DII/G2:006', 14674),
(43, 'La Curva', NULL, 7, 3, 57, 0.93, 0.93, NULL, 'Activa', 'JU-NH-DII/G2:007', 4278),
(44, 'El Tallo', NULL, 8, 3, 58, 0.95, 0.95, NULL, 'Activa', 'JU-NH-DII/G2:008', 4370),
(45, 'El Huabo', NULL, 9, 3, 59, 1.05, 1.05, NULL, 'Activa', 'JU-NH-DII/G2:009', 4830),
(46, 'La Hierba Luisa', NULL, 10, 3, 60, 1.03, 1.03, NULL, 'Activa', 'JU-NH-DII/G2:010', 4738),
(47, 'El Pozo', NULL, 11, 3, 61, 0.98, 0.98, NULL, 'Activa', 'JU-NH-DII/G2:011', 4508),
(48, 'Santa María', NULL, 12, 3, 62, 1.27, 1.27, NULL, 'Activa', 'JU-NH-DII/G2:012', 5842),
(49, 'El Veterragón', NULL, 13, 3, 63, 0.91, 0.91, NULL, 'Activa', 'JU-NH-DII/G2:013', 4186),
(50, 'La Guaba', NULL, 14, 3, 64, 4.84, 3, NULL, 'Activa', 'JU-NH-DII/G2:014', 13800),
(51, 'Jara', NULL, 15, 3, 65, 2.73, 2.5, NULL, 'Activa', 'JU-NH-DII/G2:015', 11500),
(52, 'La Palta', NULL, 16, 3, 26, 2.82, 2.82, NULL, 'Activa', 'JU-NH-DII/G2:016', 12972),
(53, 'El Tamarindo B', NULL, 17, 3, 66, 1.02, 1.02, NULL, 'Activa', 'JU-NH-DII/G2:017', 4692),
(54, 'El Tamarindo A', NULL, 18, 3, 66, 0.9, 0.9, NULL, 'Activa', 'JU-NH-DII/G2:018', 4140),
(55, 'El Algarrobo', NULL, 19, 3, 5, 1.23, 1.23, NULL, 'Activa', 'JU-NH-DII/G2:019', 5658),
(56, 'El Mango', NULL, 20, 3, 67, 2.27, 2.27, NULL, 'Activa', 'JU-NH-DII/G2:020', 10442),
(57, 'El Manantial', NULL, 21, 3, 68, 4.88, 4, NULL, 'Activa', 'JU-NH-DII/G2:021', 18400),
(58, 'El Elefante', NULL, 22, 3, 39, 5.15, 5.15, NULL, 'Activa', 'JU-NH-DII/G2:022', 23690),
(59, 'Los Mangos', NULL, 23, 3, 69, 2.06, 2.06, NULL, 'Activa', 'JU-NH-DII/G2:023', 9476),
(60, 'El Algarrobo', NULL, 24, 3, 70, 3.06, 3.06, NULL, 'Activa', 'JU-NH-DII/G2:024', 14076),
(61, 'La 16', NULL, 25, 3, 28, 5.07, 5.07, NULL, 'Activa', 'JU-NH-DII/G2:025', 23322),
(62, 'Las Gviotas', NULL, 26, 3, 37, 3.84, 1.5, NULL, 'Activa', 'JU-NH-DII/G2:026', 6900),
(63, 'La Ponderosa', NULL, 27, 3, 71, 1.08, 1.08, NULL, 'Activa', 'JU-NH-DII/G2:027', 4968),
(64, 'Las Tunas', NULL, 28, 3, 72, 1.6, 1.6, NULL, 'Activa', 'JU-NH-DII/G2:028', 7360),
(65, 'Beal', NULL, 29, 3, 73, 8.2, 4, NULL, 'Activa', 'JU-NH-DII/G2:029', 18400),
(66, 'El Plátano', NULL, 30, 3, 74, 1.73, 1.73, NULL, 'Activa', 'JU-NH-DII/G2:030', 7958),
(67, 'La Caña', NULL, 31, 3, 75, 1.54, 1.54, NULL, 'Activa', 'JU-NH-DII/G2:031', 7084),
(68, 'La Huaba', NULL, 32, 3, 76, 1.41, 1.41, NULL, 'Activa', 'JU-NH-DII/G2:032', 6486),
(69, 'El Algarrobo', NULL, 33, 3, 77, 0.52, 0.52, NULL, 'Activa', 'JU-NH-DII/G2:033', 2392),
(70, 'El Laurel', NULL, 34, 3, 78, 1.47, 1.47, NULL, 'Activa', 'JU-NH-DII/G2:034', 6762),
(71, 'La Huayaba', NULL, 35, 3, 79, 1.5, 1.5, NULL, 'Activa', 'JU-NH-DII/G2:035', 6900),
(72, 'El Frejol', NULL, 36, 3, 80, 1.68, 1.68, NULL, 'Activa', 'JU-NH-DII/G2:036', 7728),
(73, 'La Taya', NULL, 37, 3, 81, 1.65, 1.65, NULL, 'Activa', 'JU-NH-DII/G2:037', 7590),
(74, 'Jesús', NULL, 38, 3, 82, 3.98, 3.98, NULL, 'Activa', 'JU-NH-DII/G2:038', 18308),
(75, 'El Rocio', NULL, 39, 3, 83, 5, 3, NULL, 'Activa', 'JU-NH-DII/G2:039', 13800),
(76, 'El Pacayal A', NULL, 40, 3, 84, 5.76, 3, NULL, 'Activa', 'JU-NH-DII/G2:040', 13800),
(77, 'El Pacayal B', NULL, 41, 3, 84, 4.48, 3, NULL, 'Activa', 'JU-NH-DII/G2:041', 13800),
(78, 'El Espino', NULL, 42, 3, 85, 4.98, 3, NULL, 'Activa', 'JU-NH-DII/G2:042', 13800),
(79, 'La Granja', NULL, 43, 3, 86, 5.13, 5.13, NULL, 'Activa', 'JU-NH-DII/G2:043', 23598),
(80, 'Los Rosales', NULL, 44, 3, 87, 4.94, 4.94, NULL, 'Activa', 'JU-NH-DII/G2:044', 22724),
(81, 'Don Pedrito', NULL, 45, 3, 88, 1.96, 1.96, NULL, 'Activa', 'JU-NH-DII/G2:045', 906),
(82, 'El Mango', NULL, 46, 3, 2, 4.98, 3, NULL, 'Activa', 'JU-NH-DII/G2:046', 13800),
(83, 'Los Girasoles', NULL, 47, 3, 89, 5.07, NULL, NULL, 'Activa', 'JU-NH-DII/G2:047', 13800),
(84, 'Pampa Hermosa', NULL, 48, 3, 90, 3.28, 3.28, NULL, 'Activa', 'JU-NH-DII/G2:048', 15088),
(85, 'Parcela 125', NULL, 48, 3, 91, 1.53, 1.53, NULL, 'Activa', 'JU-NH-DII/G2:048', 7038),
(86, 'El Algarrobo', NULL, 50, 3, 27, 4.87, 4.87, NULL, 'Activa', 'JU-NH-DII/G2:050', 22402),
(87, 'La 30', NULL, 51, 3, 92, 4.98, 2, NULL, 'Activa', 'JU-NH-DII/G2:051', 9200),
(88, 'La Granada', NULL, 52, 3, 93, 4.89, 4.89, NULL, 'Activa', 'JU-NH-DII/G2:052', 22494),
(89, 'La Ciruela', NULL, 53, 3, 94, 5.03, 5.03, NULL, 'Activa', 'JU-NH-DII/G2:053', 23138),
(90, 'El Rancho del Tío Beny', NULL, 54, 3, 95, 5.02, 5.02, NULL, 'Activa', 'JU-NH-DII/G2:054', 23092),
(91, 'La Tía Fela 2', NULL, 55, 3, 48, 3.87, 3.87, NULL, 'Activa', 'JU-NH-DII/G2:055', 17802),
(92, 'Las Tayas', NULL, 56, 3, 96, 5.02, 5.02, NULL, 'Activa', 'JU-NH-DII/G2:056', 23092),
(93, 'Los Cocos', NULL, 57, 3, 97, 5.1, 5.1, NULL, 'Activa', 'JU-NH-DII/G2:057', 23460),
(94, 'El Algarrobo', NULL, 58, 3, 84, 5.42, 5.42, NULL, 'Activa', 'JU-NH-DII/G2:058', 24932),
(95, 'La Caña', NULL, 59, 3, 98, 2.01, 2.01, NULL, 'Activa', 'JU-NH-DII/G2:059', 9246),
(96, 'El Paraiso', NULL, 60, 3, 99, 1.94, 1.94, NULL, 'Activa', 'JU-NH-DII/G2:060', 8924),
(97, 'Bella Vista', NULL, 61, 3, 52, 4.05, 4.05, NULL, 'Activa', 'JU-NH-DII/G2:061', 18630),
(98, 'Ariana', NULL, 62, 3, 41, 3.89, 3, NULL, 'Activa', 'JU-NH-DII/G2:062', 13800),
(99, 'Los Guabos', NULL, 63, 3, 100, 2.84, 2.4, NULL, 'Activa', 'JU-NH-DII/G2:063', 13064),
(100, 'Franco', NULL, 64, 3, 101, 4.37, 4.37, NULL, 'Activa', 'JU-NH-DII/G2:064', 20102),
(101, 'El Mirador', NULL, 65, 3, 102, 5.03, 5.03, NULL, 'Activa', 'JU-NH-DII/G2:065', 23138),
(102, 'El Mirador', NULL, 66, 3, 103, 5.61, 5.61, NULL, 'Activa', 'JU-NH-DII/G2:066', 25806),
(103, 'El Mirador', NULL, 67, 3, 104, 1.8, 1.8, NULL, 'Activa', 'JU-NH-DII/G2:067', 8280),
(104, 'El Porvenir', NULL, 68, 3, 105, 2.32, 2.32, NULL, 'Activa', 'JU-NH-DII/G2:068', 10672),
(105, 'El Mirador', NULL, 69, 3, 106, 1, 1, NULL, 'Activa', 'JU-NH-DII/G2:069', 4600),
(106, 'La Huaba', NULL, 70, 3, 107, 1.92, 1.92, NULL, 'Activa', 'JU-NH-DII/G2:070', 8832),
(107, 'La Palta', NULL, 71, 3, 26, 2.06, 2.06, NULL, 'Activa', 'JU-NH-DII/G2:071', 9476),
(108, 'El Mamey', NULL, 72, 3, 108, 3.89, 3.89, NULL, 'Activa', 'JU-NH-DII/G2:072', 17894),
(109, 'Perla Verde', NULL, 73, 3, 59, 4.09, 4.09, NULL, 'Activa', 'JU-NH-DII/G2:073', 18814),
(110, 'La Naranja', NULL, 74, 4, 109, 4.01, 4.01, NULL, 'Activa', 'JU-NH-DII/G2:074', 18446),
(111, 'Las Gemelas', NULL, 75, 3, 110, 4.04, 4, NULL, 'Activa', 'JU-NH-DII/G2:075', 18400),
(112, 'El Naranjal', NULL, 76, 3, 38, 3.95, 3.95, NULL, 'Activa', 'JU-NH-DII/G2:076', 18170),
(113, 'El Cerro', NULL, 77, 3, 55, 4.74, 4.74, NULL, 'Activa', 'JU-NH-DII/G2:077', 21804),
(114, 'Las Brisas', NULL, 78, 3, 111, 4.3, 4, NULL, 'Activa', 'JU-NH-DII/G2:078', 18400),
(115, 'El Algarrobo', NULL, 79, 3, 112, 8.36, 5, NULL, 'Activa', 'JU-NH-DII/G2:079', 23000),
(116, 'La Picina', NULL, 80, 3, 113, 3.57, 3, NULL, 'Activa', 'JU-NH-DII/G2:080', 13800);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reparto`
--

CREATE TABLE `reparto` (
  `id_reparto` int(11) NOT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `fecha_reparto` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `reparto`
--

INSERT INTO `reparto` (`id_reparto`, `descripcion`, `tipo`, `fecha_registro`, `fecha_reparto`) VALUES
(4, NULL, 'General', '2018-11-09', '2018-11-16 17:00:00'),
(7, NULL, 'Para Chayas', '2018-11-07', '2018-11-10 16:00:00'),
(8, NULL, 'Especial', '2018-11-10', '2018-11-11 16:00:00'),
(9, NULL, 'General', '2018-11-22', '2018-11-25 16:00:00'),
(10, 'aaaa', 'General', '2018-11-26', '2018-11-10 16:30:00'),
(11, 'bbb', 'Especial', '2018-11-26', '2018-11-10 16:00:00'),
(12, 'w', 'Para Chayas', NULL, '2019-07-19 00:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `talonario`
--

CREATE TABLE `talonario` (
  `id_talonario` int(11) NOT NULL,
  `codigo` int(11) DEFAULT NULL,
  `descripcion` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `primer_ticket` int(11) DEFAULT NULL,
  `cantidad_tickets` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_futbolistas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_futbolistas` (
`id_parcela` int(11)
,`nombre` varchar(60)
,`ubicacion` varchar(150)
,`num_toma` int(11)
,`id_canal` int(11)
,`id_auth_user` int(11)
,`total_has` double
,`has_sembradas` double
,`descripcion` varchar(100)
,`estado` varchar(15)
,`codigo_predio` varchar(25)
,`volumen_agua` float
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_parcelas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_parcelas` (
`id_parcela` int(11)
,`nombre` varchar(60)
,`ubicacion` varchar(150)
,`num_toma` int(11)
,`id_canal` int(11)
,`id_auth_user` int(11)
,`total_has` double
,`has_sembradas` double
,`descripcion` varchar(100)
,`estado` varchar(15)
,`codigo_predio` varchar(25)
,`volumen_agua` float
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_futbolistas`
--
DROP TABLE IF EXISTS `vista_futbolistas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_futbolistas`  AS  (select `p`.`id_parcela` AS `id_parcela`,`p`.`nombre` AS `nombre`,`p`.`ubicacion` AS `ubicacion`,`p`.`num_toma` AS `num_toma`,`p`.`id_canal` AS `id_canal`,`p`.`id_auth_user` AS `id_auth_user`,`p`.`total_has` AS `total_has`,`p`.`has_sembradas` AS `has_sembradas`,`p`.`descripcion` AS `descripcion`,`p`.`estado` AS `estado`,`p`.`codigo_predio` AS `codigo_predio`,`p`.`volumen_agua` AS `volumen_agua` from (`parcela` `p` join `canal` `c` on((`p`.`id_canal` = `c`.`id_canal`))) where (`c`.`id_canal` = 3)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_parcelas`
--
DROP TABLE IF EXISTS `v_parcelas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_parcelas`  AS  select `p`.`id_parcela` AS `id_parcela`,`p`.`nombre` AS `nombre`,`p`.`ubicacion` AS `ubicacion`,`p`.`num_toma` AS `num_toma`,`p`.`id_canal` AS `id_canal`,`p`.`id_auth_user` AS `id_auth_user`,`p`.`total_has` AS `total_has`,`p`.`has_sembradas` AS `has_sembradas`,`p`.`descripcion` AS `descripcion`,`p`.`estado` AS `estado`,`p`.`codigo_predio` AS `codigo_predio`,`p`.`volumen_agua` AS `volumen_agua` from (`parcela` `p` join `canal` `c` on((`p`.`id_canal` = `c`.`id_canal`))) where (`c`.`id_canal` = 3) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  ADD PRIMARY KEY (`id_agenda`),
  ADD KEY `fk_asa_age_idx` (`id_asamblea`);

--
-- Indices de la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  ADD PRIMARY KEY (`id_archivos_parcela`),
  ADD KEY `fk_par_arc_idx` (`id_parcela`);

--
-- Indices de la tabla `asamblea`
--
ALTER TABLE `asamblea`
  ADD PRIMARY KEY (`id_asamblea`);

--
-- Indices de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indices de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indices de la tabla `auth_user`
--
ALTER TABLE `auth_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indices de la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  ADD KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`);

--
-- Indices de la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  ADD KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `canal`
--
ALTER TABLE `canal`
  ADD PRIMARY KEY (`id_canal`);

--
-- Indices de la tabla `caudal`
--
ALTER TABLE `caudal`
  ADD PRIMARY KEY (`id_caudal`),
  ADD KEY `fk_can_cau_idx` (`id_canal`);

--
-- Indices de la tabla `comite`
--
ALTER TABLE `comite`
  ADD PRIMARY KEY (`id_comite`);

--
-- Indices de la tabla `comprobante`
--
ALTER TABLE `comprobante`
  ADD PRIMARY KEY (`id_comprobante`),
  ADD KEY `fk_tal_comp_idx` (`id_talonario`);

--
-- Indices de la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  ADD PRIMARY KEY (`id_comp_multa`),
  ADD KEY `fk_mul_comp_mul_idx` (`id_multa`),
  ADD KEY `fk_comp_comp_mul_idx` (`id_comprobante`);

--
-- Indices de la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  ADD PRIMARY KEY (`id_comp_orden`),
  ADD KEY `fk_comp_comp_ord_idx` (`id_comprobante`),
  ADD KEY `fk_ord_comp_ord_idx` (`id_orden`);

--
-- Indices de la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  ADD PRIMARY KEY (`id_datos_personales`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `destajo`
--
ALTER TABLE `destajo`
  ADD PRIMARY KEY (`id_destajo`),
  ADD KEY `fk_can_des_idx` (`id_canal`),
  ADD KEY `fk_par_des_idx` (`id_parcela`);

--
-- Indices de la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  ADD PRIMARY KEY (`id_det_limpieza`),
  ADD KEY `fk_des_det_idx` (`id_destajo`),
  ADD KEY `fk_lim_det_idx` (`id_limpieza`);

--
-- Indices de la tabla `det_lista`
--
ALTER TABLE `det_lista`
  ADD PRIMARY KEY (`id_det_lista`),
  ADD KEY `fk_lis_det_lis_idx` (`id_lista`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `direccion`
--
ALTER TABLE `direccion`
  ADD PRIMARY KEY (`id_direccion`),
  ADD KEY `fk_per_dir_idx` (`id_datos_personales`);

--
-- Indices de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`);

--
-- Indices de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indices de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indices de la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  ADD PRIMARY KEY (`id_hoja_asistencia`),
  ADD KEY `fk_asam_asis_idx` (`id_asamblea`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `limpieza`
--
ALTER TABLE `limpieza`
  ADD PRIMARY KEY (`id_limpieza`);

--
-- Indices de la tabla `lista`
--
ALTER TABLE `lista`
  ADD PRIMARY KEY (`id_lista`),
  ADD KEY `fk_com_lis_idx` (`id_comite`);

--
-- Indices de la tabla `multa`
--
ALTER TABLE `multa`
  ADD PRIMARY KEY (`id_multa`);

--
-- Indices de la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  ADD PRIMARY KEY (`id_multa_asistencia`),
  ADD KEY `fk_mul_asis_idx` (`id_multa`),
  ADD KEY `fk_asi_mul_asi_idx` (`id_hoja_asistencia`);

--
-- Indices de la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  ADD PRIMARY KEY (`id_multa_limpia`),
  ADD KEY `fk_mul_mul_lim_idx` (`id_multa`),
  ADD KEY `fk_det_lim_mul_lim_idx` (`id_det_limpia`);

--
-- Indices de la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  ADD PRIMARY KEY (`id_multa_orden`),
  ADD KEY `fk_mul_ord_idx` (`id_orden`),
  ADD KEY `fk_mul_mul_ord_idx` (`id_multa`);

--
-- Indices de la tabla `noticia`
--
ALTER TABLE `noticia`
  ADD PRIMARY KEY (`id_noticia`);

--
-- Indices de la tabla `obra`
--
ALTER TABLE `obra`
  ADD PRIMARY KEY (`id_obra`),
  ADD KEY `fk_can_obr_idx` (`id_canal`);

--
-- Indices de la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  ADD PRIMARY KEY (`id_orden_riego`),
  ADD KEY `fk_rep_ord_idx` (`id_reparto`),
  ADD KEY `fk_par_ord_idx` (`id_parcela`);

--
-- Indices de la tabla `parcela`
--
ALTER TABLE `parcela`
  ADD PRIMARY KEY (`id_parcela`),
  ADD KEY `fk_can_par_idx` (`id_canal`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `reparto`
--
ALTER TABLE `reparto`
  ADD PRIMARY KEY (`id_reparto`);

--
-- Indices de la tabla `talonario`
--
ALTER TABLE `talonario`
  ADD PRIMARY KEY (`id_talonario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  MODIFY `id_agenda` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  MODIFY `id_archivos_parcela` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `asamblea`
--
ALTER TABLE `asamblea`
  MODIFY `id_asamblea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=194;

--
-- AUTO_INCREMENT de la tabla `auth_user`
--
ALTER TABLE `auth_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT de la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `canal`
--
ALTER TABLE `canal`
  MODIFY `id_canal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `caudal`
--
ALTER TABLE `caudal`
  MODIFY `id_caudal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `comite`
--
ALTER TABLE `comite`
  MODIFY `id_comite` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comprobante`
--
ALTER TABLE `comprobante`
  MODIFY `id_comprobante` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  MODIFY `id_comp_multa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  MODIFY `id_comp_orden` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  MODIFY `id_datos_personales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `destajo`
--
ALTER TABLE `destajo`
  MODIFY `id_destajo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  MODIFY `id_det_limpieza` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `det_lista`
--
ALTER TABLE `det_lista`
  MODIFY `id_det_lista` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `direccion`
--
ALTER TABLE `direccion`
  MODIFY `id_direccion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  MODIFY `id_hoja_asistencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3539;

--
-- AUTO_INCREMENT de la tabla `limpieza`
--
ALTER TABLE `limpieza`
  MODIFY `id_limpieza` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `lista`
--
ALTER TABLE `lista`
  MODIFY `id_lista` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa`
--
ALTER TABLE `multa`
  MODIFY `id_multa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  MODIFY `id_multa_asistencia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  MODIFY `id_multa_limpia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  MODIFY `id_multa_orden` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `noticia`
--
ALTER TABLE `noticia`
  MODIFY `id_noticia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `obra`
--
ALTER TABLE `obra`
  MODIFY `id_obra` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  MODIFY `id_orden_riego` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `parcela`
--
ALTER TABLE `parcela`
  MODIFY `id_parcela` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT de la tabla `reparto`
--
ALTER TABLE `reparto`
  MODIFY `id_reparto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `talonario`
--
ALTER TABLE `talonario`
  MODIFY `id_talonario` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  ADD CONSTRAINT `fk_asa_age` FOREIGN KEY (`id_asamblea`) REFERENCES `asamblea` (`id_asamblea`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  ADD CONSTRAINT `fk_par_arc` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Filtros para la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Filtros para la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  ADD CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `caudal`
--
ALTER TABLE `caudal`
  ADD CONSTRAINT `fk_can_cau` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comprobante`
--
ALTER TABLE `comprobante`
  ADD CONSTRAINT `fk_tal_comp` FOREIGN KEY (`id_talonario`) REFERENCES `talonario` (`id_talonario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  ADD CONSTRAINT `fk_comp_comp_mul` FOREIGN KEY (`id_comprobante`) REFERENCES `comprobante` (`id_comprobante`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_comp_mul` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  ADD CONSTRAINT `fk_comp_comp_ord` FOREIGN KEY (`id_comprobante`) REFERENCES `comprobante` (`id_comprobante`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_ord_comp_ord` FOREIGN KEY (`id_orden`) REFERENCES `orden_riego` (`id_orden_riego`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  ADD CONSTRAINT `datos_personales_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `destajo`
--
ALTER TABLE `destajo`
  ADD CONSTRAINT `fk_can_des` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_par_des` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  ADD CONSTRAINT `fk_des_det` FOREIGN KEY (`id_destajo`) REFERENCES `destajo` (`id_destajo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_lim_det` FOREIGN KEY (`id_limpieza`) REFERENCES `limpieza` (`id_limpieza`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `det_lista`
--
ALTER TABLE `det_lista`
  ADD CONSTRAINT `det_lista_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`),
  ADD CONSTRAINT `fk_lis_det_lis` FOREIGN KEY (`id_lista`) REFERENCES `lista` (`id_lista`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `direccion`
--
ALTER TABLE `direccion`
  ADD CONSTRAINT `fk_per_dir` FOREIGN KEY (`id_datos_personales`) REFERENCES `datos_personales` (`id_datos_personales`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  ADD CONSTRAINT `fk_asamblea_hoja_asistencia` FOREIGN KEY (`id_asamblea`) REFERENCES `asamblea` (`id_asamblea`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `hoja_asistencia_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `lista`
--
ALTER TABLE `lista`
  ADD CONSTRAINT `fk_com_lis` FOREIGN KEY (`id_comite`) REFERENCES `comite` (`id_comite`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  ADD CONSTRAINT `fk_asi_mul_asi` FOREIGN KEY (`id_hoja_asistencia`) REFERENCES `hoja_asistencia` (`id_hoja_asistencia`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_asis` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  ADD CONSTRAINT `fk_det_lim_mul_lim` FOREIGN KEY (`id_det_limpia`) REFERENCES `det_limpieza` (`id_det_limpieza`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_mul_lim` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  ADD CONSTRAINT `fk_mul_mul_ord` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_ord` FOREIGN KEY (`id_orden`) REFERENCES `orden_riego` (`id_orden_riego`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `obra`
--
ALTER TABLE `obra`
  ADD CONSTRAINT `fk_can_obr` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  ADD CONSTRAINT `fk_par_ord` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_rep_ord` FOREIGN KEY (`id_reparto`) REFERENCES `reparto` (`id_reparto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `parcela`
--
ALTER TABLE `parcela`
  ADD CONSTRAINT `fk_can_par` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `parcela_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
