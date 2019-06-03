
/*				CREAR VIEW 	 */
BEGIN
	DECLARE tam int;
    set @tam = 0;

	DROP VIEW v_parcelas;
	CREATE VIEW v_parcelas AS 
    SELECT  p.* FROM parcela p
    INNER JOIN canal c
    	ON p.id_canal = c.id_canal 
    WHERE c.id_canal = 3;
    
    SET @tam = (SELECT COUNT(*) FROM v_parcelas);
    SELECT @tam AS TAMAÑO;
END

/*/             delete          */
DELETE FROM `hoja_asistencia` WHERE id_asamblea = 1


/*				CREAR CURSOR	 */
BEGIN
	DECLARE id int;
    DECLARE cur1 CURSOR FOR (SELECT id_parcela FROM parcela);     

    OPEN cur1;
    read_loop: LOOP
    	FETCH cur1 INTO id;
        SELECT id as ID;
     END LOOP;
     CLOSE cur1;
END



--=================================PROCEDIMIETNO ALMACENADO

DELIMITER //
CREATE PROCEDURE sp_prueba()
BEGIN
	DECLARE cant int;
    DECLARE itr int;
    DECLARE str varchar(500);
    
    set @cant = 23;
    set @itr =0;
    set @str =">>";
    
    SET @cant = (SELECT COUNT(p.id_parcela) 
    FROM parcela p
        inner join canal c
            on p.id_canal = c.id_canal 
    WHERE c.id_canal = 3);

    SELECT @cant as CANIDAD;
    
    while @itr < @cant do
    	set @str = concat(@str,"-",@itr);
        set @itr = @itr + 1;
  	end while;
    
    SELECT @str as TODOS;
END
//
DELIMITER ;


---========================= cuantas parcelas por canal de id 2
select 
	COUNT(p.id_parcela)
FROM parcela p
inner join canal c 
	on p.id_canal = c.id_canal
WHERE c.id_canal = 2



-- ==================== INSERTAR
create procedure insertar_usuarios (in addusuario varchar(15), in addpassword varchar(15))
begin
declare existe int;
select count(usuario) into existe from usuarios where usuario=addusuario;
if existe then
   select 'el usuario ya existe' as mensaje;
else
   insert into usuarios(usuario,password) values(addusuario,addpassword);
   select 'los datos se insertaron correctamente' as mensaje;
end if;
end