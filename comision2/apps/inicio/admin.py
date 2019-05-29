from django.contrib import admin

# Register your models here.


from apps.inicio.models import (AgendaAsamblea,Asamblea,ArchivosParcela,
	Canal,Caudal,Comite,Comprobante,DatosPersonales,Destajo,DetLimpieza,
	DetLista,Direccion,HojaAsistencia,Limpieza)


admin.site.register(AgendaAsamblea)
admin.site.register(Asamblea)
admin.site.register(ArchivosParcela)
admin.site.register(Canal)
admin.site.register(Caudal)
admin.site.register(Comite)
admin.site.register(Comprobante)
admin.site.register(DatosPersonales)
admin.site.register(Destajo)
admin.site.register(DetLimpieza)
admin.site.register(DetLista)
admin.site.register(Direccion)
admin.site.register(HojaAsistencia)
admin.site.register(Limpieza)
"""
admin.site.register(DetLista)
admin.site.register(Comprobante)
admin.site.register(Comite)
admin.site.register(Canal)
admin.site.register(Noticia)
admin.site.register(Asamblea)
admin.site.register(Acceso)
"""