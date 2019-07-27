# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
#from django.contrib.auth.models import User

# En este punto, el usuario es un objeto User que ya se ha guardado
# a la base de datos. Puedes continuar cambiando sus atributos
# si desea cambiar otros campos.

from django.utils.translation import ugettext as _


class AgendaAsamblea(models.Model):
    id_agenda = models.AutoField(primary_key=True)
    id_asamblea = models.ForeignKey('Asamblea', models.DO_NOTHING, db_column='id_asamblea', blank=True, null=True)
    punto_numero = models.IntegerField(blank=True, null=True)
    descripcion = models.CharField(max_length=400, blank=True, null=True)
    foto = models.CharField(max_length=150, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'agenda_asamblea'


class ArchivosParcela(models.Model):
    id_archivos_parcela = models.AutoField(primary_key=True)
    id_parcela = models.ForeignKey('Parcela', models.DO_NOTHING, db_column='id_parcela', blank=True, null=True)
    descripcion = models.CharField(max_length=45, blank=True, null=True)
    archivo = models.CharField(max_length=150, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'archivos_parcela'
#foto = models.ImageField(upload_to='photos')

class Asamblea(models.Model):
    TIPO = (
        ('General', 'REUNIÓN GENERAL'),
        ('Simple', 'REUNIÓN SIMPLE'),
    )
    id_asamblea = models.AutoField(primary_key=True)
    tipo = models.CharField(max_length=15, blank=True, null=True, choices=TIPO)
    descripcion = models.CharField(max_length=300, blank=True, null=True)
    fecha_registro = models.DateTimeField(blank=True, null=True)
    fecha_asamblea = models.DateTimeField(blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asamblea'





class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=80)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)

 
class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.IntegerField(default=0)
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.IntegerField(default=0)
    is_active = models.IntegerField(default=1)
    date_joined = models.DateTimeField(default="2000-01-01 10:00:01")
    dni = models.IntegerField()


    class Meta:
        managed = False
        db_table = 'auth_user'

        permissions = (
            ('es_presidente',_('Presidente')),
            ('es_canalero',_('Canalero')),
            ('es_tesorero',_('Tesorero')),
            ('es_vocal',_('Vocal')),
            ('es_usuario',_('Usuario')),
        )

    def Usuario(self):
        cadena="{0}, {1} [{2}]"
        return cadena.format(self.first_name,self.last_name,self.id)
        
    def __str__(self):
        return self.Usuario()


    def get_full_name(sel):
        cadena="{0}, {1} [{2}]"
        return cadena.format(self.first_name,self.last_name,self.id)


class AuthUserGroups(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class Canal(models.Model):
    id_canal = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=45, blank=True, null=True)
    tamano = models.FloatField(blank=True, null=True)
    ubicacion = models.CharField(max_length=45, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'canal'

    def __str__(self):
        cadena="[{0}] {1}"
        return cadena.format(self.id_canal,self.nombre)


class Caudal(models.Model):
    id_caudal = models.AutoField(primary_key=True)
    id_canal = models.ForeignKey(Canal, models.DO_NOTHING, db_column='id_canal', blank=True, null=True)
    fecha = models.DateTimeField(blank=True, null=True)
    nivel = models.IntegerField(blank=True, null=True)
    descripcion = models.CharField(max_length=45, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'caudal'


class Comite(models.Model):
    id_comite = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=100, blank=True, null=True)
    descripcion = models.CharField(max_length=200, blank=True, null=True)
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'comite'
        
    def __str__(self):
        cadena = "[{0}] {1}"
        return cadena.format(self.id_canal,self.nombre)

class CompMulta(models.Model):
    id_comp_multa = models.AutoField(primary_key=True)
    id_comprobante = models.ForeignKey('Comprobante', models.DO_NOTHING, db_column='id_comprobante')
    id_multa = models.ForeignKey('Multa', models.DO_NOTHING, db_column='id_multa')

    class Meta:
        managed = False
        db_table = 'comp_multa'


class CompOrden(models.Model):
    id_comp_orden = models.AutoField(primary_key=True)
    id_comprobante = models.ForeignKey('Comprobante', models.DO_NOTHING, db_column='id_comprobante')
    id_orden = models.ForeignKey('OrdenRiego', models.DO_NOTHING, db_column='id_orden')

    class Meta:
        managed = False
        db_table = 'comp_orden'


class Comprobante(models.Model):
    id_comprobante = models.AutoField(primary_key=True)
    id_talonario = models.ForeignKey('Talonario', models.DO_NOTHING, db_column='id_talonario')
    ticket_numero = models.IntegerField(blank=True, null=True)
    concepto = models.CharField(max_length=100, blank=True, null=True)
    tipo = models.CharField(max_length=45, blank=True, null=True)
    monto = models.FloatField(blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'comprobante'


class DatosPersonales(models.Model):
    id_datos_personales = models.AutoField(primary_key=True)
    dni = models.CharField(max_length=8, blank=True, null=True)
    alias = models.CharField(max_length=20, blank=True, null=True)
    sexo = models.CharField(max_length=1, blank=True, null=True)
    fecha_nacimiento = models.DateField(blank=True, null=True)
    telefono = models.CharField(max_length=20, blank=True, null=True)
    celular = models.CharField(max_length=13, blank=True, null=True)
    foto = models.ImageField(upload_to='photos')
    id_auth_user = models.ForeignKey(AuthUser, models.DO_NOTHING, db_column='id_auth_user', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'datos_personales'


class Destajo(models.Model):
    id_destajo = models.AutoField(primary_key=True)
    id_canal = models.ForeignKey(Canal, models.DO_NOTHING, db_column='id_canal', blank=True, null=True)
    id_parcela = models.ForeignKey('Parcela', models.DO_NOTHING, db_column='id_parcela', blank=True, null=True)
    tamano = models.FloatField(blank=True, null=True)
    num_orden = models.IntegerField(blank=True, null=True)
    fecha_registro = models.DateField(blank=True, null=True, editable=False)
    descripcion = models.CharField(max_length=45, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'destajo'


class DetLimpieza(models.Model):
    id_det_limpieza = models.AutoField(primary_key=True)
    id_destajo = models.ForeignKey(Destajo, models.DO_NOTHING, db_column='id_destajo', blank=True, null=True)
    id_limpieza = models.ForeignKey('Limpieza', models.DO_NOTHING, db_column='id_limpieza', blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True)
    fecha = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'det_limpieza'


class DetLista(models.Model):
    id_det_lista = models.AutoField(primary_key=True)
    id_lista = models.ForeignKey('Lista', models.DO_NOTHING, db_column='id_lista', blank=True, null=True)
    id_auth_user = models.ForeignKey(AuthUser, models.DO_NOTHING, db_column='id_auth_user', blank=True, null=True)
    cargo = models.CharField(max_length=20, blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'det_lista'


class Direccion(models.Model):
    id_direccion = models.AutoField(primary_key=True)
    id_datos_personales = models.ForeignKey(DatosPersonales, models.DO_NOTHING, db_column='id_datos_personales', blank=True, null=True)
    pais = models.CharField(max_length=20, blank=True, null=True)
    cod_postal = models.IntegerField(blank=True, null=True)
    departamento = models.CharField(max_length=20, blank=True, null=True)
    provinciaa = models.CharField(max_length=20, blank=True, null=True)
    distrito = models.CharField(max_length=20, blank=True, null=True)
    dir_larga = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'direccion'


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.PositiveSmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class HojaAsistencia(models.Model):
    id_hoja_asistencia = models.AutoField(primary_key=True)
    id_asamblea = models.ForeignKey(Asamblea, models.DO_NOTHING, db_column='id_asamblea')
    id_auth_user = models.ForeignKey(AuthUser, models.DO_NOTHING, db_column='id_auth_user')
    estado = models.CharField(max_length=15)
    hora = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'hoja_asistencia'


class Limpieza(models.Model):
    id_limpieza = models.AutoField(primary_key=True)
    decripcion = models.CharField(max_length=45, blank=True, null=True)
    tipo = models.CharField(max_length=15, blank=True, null=True)
    fecha_registro = models.DateField(blank=True, null=True)
    fecha_limpieza = models.DateField(blank=True, null=True)
    fecha_revision = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'limpieza'


class Lista(models.Model):
    id_lista = models.AutoField(primary_key=True)
    id_comite = models.ForeignKey(Comite, models.DO_NOTHING, db_column='id_comite', blank=True, null=True)
    nombre_lista = models.CharField(max_length=100, blank=True, null=True)
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    estado = models.CharField(max_length=20, blank=True, null=True)
    foto = models.CharField(max_length=150, blank=True, null=True)
    fecha_inicio = models.DateField(blank=True, null=True)
    fecha_termino = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'lista'


class Multa(models.Model):
    id_multa = models.AutoField(primary_key=True)
    concepto = models.CharField(max_length=100, blank=True, null=True)
    fecha = models.DateTimeField(blank=True, null=True)
    estado = models.CharField(max_length=10, blank=True, null=True)
    tipo = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'multa'


class MultaAsistencia(models.Model):
    id_multa_asistencia = models.AutoField(primary_key=True)
    id_multa = models.ForeignKey(Multa, models.DO_NOTHING, db_column='id_multa')
    id_hoja_asistencia = models.ForeignKey(HojaAsistencia, models.DO_NOTHING, db_column='id_hoja_asistencia')

    class Meta:
        managed = False
        db_table = 'multa_asistencia'


class MultaLimpia(models.Model):
    id_multa_limpia = models.AutoField(primary_key=True)
    id_multa = models.ForeignKey(Multa, models.DO_NOTHING, db_column='id_multa')
    id_det_limpia = models.ForeignKey(DetLimpieza, models.DO_NOTHING, db_column='id_det_limpia')

    class Meta:
        managed = False
        db_table = 'multa_limpia'


class MultaOrden(models.Model):
    id_multa_orden = models.AutoField(primary_key=True)
    id_orden = models.ForeignKey('OrdenRiego', models.DO_NOTHING, db_column='id_orden')
    id_multa = models.ForeignKey(Multa, models.DO_NOTHING, db_column='id_multa')

    class Meta:
        managed = False
        db_table = 'multa_orden'


class Noticia(models.Model):
    id_noticia = models.AutoField(primary_key=True)
    titular = models.CharField(max_length=45, blank=True, null=True)
    descripcion = models.CharField(max_length=400, blank=True, null=True)
    fecha = models.DateTimeField(blank=True, null=True)
    foto = models.ImageField(upload_to='photos')

    class Meta:
        managed = False
        db_table = 'noticia'


class Obra(models.Model):
    id_obra = models.AutoField(primary_key=True)
    id_canal = models.ForeignKey(Canal, models.DO_NOTHING, db_column='id_canal', blank=True, null=True)
    decripcion = models.CharField(max_length=100, blank=True, null=True)
    fecha = models.DateField(blank=True, null=True)
    monto = models.FloatField(blank=True, null=True)
    foto = models.CharField(max_length=150, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'obra'


class OrdenRiego(models.Model):
    id_orden_riego = models.AutoField(primary_key=True)
    id_reparto = models.ForeignKey('Reparto', models.DO_NOTHING, db_column='id_reparto', blank=True, null=True)
    id_parcela = models.ForeignKey('Parcela', models.DO_NOTHING, db_column='id_parcela', blank=True, null=True)
    fecha_establecida = models.DateField(blank=True, null=True)
    fecha_inicio = models.DateTimeField(blank=True, null=True)
    duracion = models.FloatField(blank=True, null=True)
    unidad = models.CharField(max_length=15, blank=True, null=True)
    cantidad_has = models.FloatField(blank=True, null=True)
    importe = models.FloatField(blank=True, null=True)
    estado = models.CharField(max_length=20, blank=True, null=True)
    id_comprobante = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'orden_riego'

 


class Parcela(models.Model):
    ESTADO = (
        ('ACTIVA', 'ACTIVA'),
        ('REGISTRADA', 'REGISTRADA'),
    )
    id_parcela = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=60, blank=True, null=True)
    codigo_predio = models.CharField(max_length=25, blank=True, null=True)
    ubicacion = models.CharField(max_length=150, blank=True, null=True)
    num_toma = models.IntegerField(blank=True, null=True)
    id_canal = models.ForeignKey(Canal, models.DO_NOTHING, db_column='id_canal', blank=True, null=True)
    id_auth_user = models.ForeignKey(AuthUser, models.DO_NOTHING, db_column='id_auth_user', blank=True, null=True)
    total_has = models.FloatField(blank=True, null=True)
    has_sembradas = models.FloatField(blank=True, null=True)
    descripcion = models.CharField(max_length=100, blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True, choices=ESTADO)
    volumen_agua = models.FloatField(blank=True, null=True)
    

    class Meta:
        managed = False
        db_table = 'parcela'

    def __str__(self):
        cadena = "[{0}] {1} - ubicada en {2}"
        return cadena.format(self.id_parcela,self.nombre, self.ubicacion)


class Reparto(models.Model):
    TIPO = (
        ('Para Chayas', 'Para Chayas '),
        ('General', 'General'),
        ('Especial', 'Especial'),
    )
    id_reparto = models.AutoField(primary_key=True)
    descripcion = models.CharField(max_length=45, blank=True, null=True)
    tipo = models.CharField(max_length=15, blank=True, null=True, choices=TIPO)
    fecha_registro = models.DateField(blank=True, null=True, editable=False)
    fecha_reparto = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reparto'

    def __str__(self):
        cadena = "[{0}] {1} - {2}"
        return cadena.format(self.id_reparto,self.tipo, self.fecha_reparto)


class Talonario(models.Model):
    id_talonario = models.AutoField(primary_key=True)
    codigo = models.IntegerField(blank=True, null=True)
    descripcion = models.CharField(max_length=150, blank=True, null=True)
    primer_ticket = models.IntegerField(blank=True, null=True)
    cantidad_tickets = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'talonario'