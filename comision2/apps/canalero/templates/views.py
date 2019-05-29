from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView, DeleteView, TemplateView, View
from apps.inicio.models import Reparto, Multa, DatosPersonales, Noticia, Parcela, Canal, Destajo, OrdenRiego
from apps.canalero.forms import RepartoForm, MultaForm, DestajoForm


from apps.presidente.forms import ParcelaForm, CanalForm, NoticiaForm
from apps.inicio.forms import PersonaForm

from django.contrib.auth.decorators import login_required, permission_required

from django.contrib.auth.models import User
from apps.presidente.forms import RegistroForm

from comision2.utileria import render_pdf


class PDFPrueba(View):
	"""
	Regresa PDF basado en template Django/HTML
	"""
	def get(self, request,*arg, **kwargs):
		pdf=render_pdf("reportes/mi_pdf.html")
		return HttpResponse(pdf,content_type="application/pdf")



class PDFPrueba2(View):

	def get(self, request,*arg, **kwargs):
		pdf=render_pdf("reportes/c_pdf_2.html")
		return HttpResponse(pdf,content_type="application/pdf")


from django.db import connection

class GrafRepC1(View):

	def get(self, request, *args, **kwargs):
		dicc={}	
		can=Canal.objects.all()
		ree=Reparto.objects.all()
		for r in ree:
			print('')
		for c in can:
			print('')


		cursor = connection.cursor()
		cursor.execute("CALL sp_ordenes_por_reparto_por_canal")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		
		dicc['sp']=result	
		for c in dicc['sp']:
			print(' ',c)
		dicc['canales']=can	
		dicc['repartos'] = ree
		print('___________________________________________________ >>',)

		return render(request,'reportes/c_graf_rep.html',dicc)

"""	
for r in dicc['repartos']:
	print('  + ree: ',r)
print(' ')
for r in dicc['canales']:
	print('   + can: ',can)
print(' ')
reporte_reparto = {}
reporte_reparto['repartos']=re
for r in re:
reporte_reparto['co',r.id_reparto]=OrdenRiego.objects.filter(id_reparto=r.id_reparto).count()
print('    -   -  >  ',r.id_reparto,'  - -  ',reporte_reparto['co',r.id_reparto])
"""


@permission_required('inicio.es_canalero')
def canalero(request):
	return render(request, 'canalero.html')







class SolicitudesPorReparto(TemplateView):

	def get(self, request, *args, **kwargs):
		idrepa = self.request.GET.get('id_repa')
		dicc={}
		dicc['reparto']=Reparto.objects.get(id_reparto=idrepa)
		dicc['repartos']=Reparto.objects.all()
		dicc['ordenes']=OrdenRiego.objects.filter(id_reparto=idrepa)
		return render(request,'c_reparto_lis_ord.html',dicc)


class AprobarOrden(TemplateView):

	def get(self, request, *args, **kwargs):
		idord = self.request.GET.get('id_ord')
		idrep = self.request.GET.get('id_rep')		
		est = self.request.GET.get('est')
		orr=OrdenRiego.objects.get(id_orden_riego=int(idord))
		orr.estado=est
		orr.save()

		dicc={}
		dicc['reparto']=Reparto.objects.get(id_reparto=idrep)
		dicc['repartos']=Reparto.objects.all()
		dicc['ordenes']=OrdenRiego.objects.filter(id_reparto=idrep)
		return render(request,'c_reparto_lis_ord.html',dicc)

class AprobarListaOrdenes(TemplateView):

	def get(self, request, *args, **kwargs):
		idrep = self.request.GET.get('id_rep')
		lo=OrdenRiego.objects.filter(id_reparto=idrep)
		for l in lo:
			l.estado='Aprobada'
			l.save()
		dicc={}
		dicc['reparto']=Reparto.objects.get(id_reparto=idrep)
		dicc['repartos']=Reparto.objects.all()
		dicc['ordenes']=OrdenRiego.objects.filter(id_reparto=idrep)
		return render(request,'c_reparto_lis_ord.html',dicc)






class DestajoCreate(CreateView):
	model=Destajo
	form_class=DestajoForm
	template_name='c_destajo_reg.html'
	success_url=reverse_lazy('c_destajo_lis')

class DestajoList(ListView):
	model=Destajo
	template_name='c_destajo_lis.html'
	paginate_by=10

class DestajoUpdate(UpdateView):
	model=Destajo
	form_class=DestajoForm
	template_name='c_destajo_reg.html'
	success_url=reverse_lazy('c_destajo_lis') 

class DestajoDelete(DeleteView):
	model=Destajo
	form_class=DestajoForm
	template_name='c_destajo_eli.html'
	success_url=reverse_lazy('c_destajo_lis')




class MultaCreate(CreateView):
	model=Multa
	form_class=MultaForm
	template_name='c_multa_reg.html'
	success_url=reverse_lazy('c_multa_lis')

class MultaList(ListView):
	model=Multa
	template_name='c_multa_lis.html'
	paginate_by=10

class MultaUpdate(UpdateView):
	model=Multa
	form_class=MultaForm
	template_name='c_multa_reg.html'
	success_url=reverse_lazy('c_multa_lis') 

class MultaDelete(DeleteView):
	model=Multa
	form_class=MultaForm
	template_name='c_multa_eli.html'
	success_url=reverse_lazy('c_multa_lis')





class CanalCreate(CreateView):
	model=Canal
	form_class=CanalForm
	template_name='c_canal_reg.html'
	success_url=reverse_lazy('c_canal_lis')

class CanalList(ListView):
	model=Canal
	template_name='c_canal_lis.html'
	paginate_by=9

class CanalUpdate(UpdateView):
	model=Canal
	form_class=CanalForm
	template_name='c_canal_reg.html'
	success_url=reverse_lazy('c_canal_lis') 

class CanalDelete(DeleteView):
	model=Canal
	form_class=CanalForm
	template_name='c_canal_eli.html'
	success_url=reverse_lazy('c_canal_lis')




class ParcelaCreate(CreateView):
	model=Parcela
	form_class=ParcelaForm
	template_name='c_parcela_reg.html'
	success_url=reverse_lazy('c_parcela_lis')

class ParcelaList(ListView):
	model=Parcela
	template_name='c_parcela_lis.html'
	paginate_by=9

class ParcelaUpdate(UpdateView):
	model=Parcela
	form_class=ParcelaForm
	template_name='c_parcela_reg.html'
	success_url=reverse_lazy('c_parcela_lis') 

class ParcelaDelete(DeleteView):
	model=Parcela
	form_class=ParcelaForm
	template_name='c_parcela_eli.html'
	success_url=reverse_lazy('c_parcela_lis')




class NoticiaCreate(CreateView):
	model=Noticia
	form_class=NoticiaForm
	template_name='c_noticia_reg.html'
	success_url=reverse_lazy('c_noticia_lis')

class NoticiaList(ListView):
	model=Noticia
	template_name='c_noticia_lis.html'
	paginate_by=9

class NoticiaUpdate(UpdateView):
	model=Noticia
	form_class=NoticiaForm
	template_name='c_noticia_reg.html'
	success_url=reverse_lazy('c_noticia_lis') 

class NoticiaDelete(DeleteView):
	model=Noticia
	form_class=NoticiaForm
	template_name='c_noticia_eli.html'
	success_url=reverse_lazy('c_noticia_lis')

 


class RepartoCreate(CreateView):
	model=Reparto
	form_class=RepartoForm
	template_name='c_reparto_reg.html'
	success_url=reverse_lazy('c_reparto_lis')

class RepartoList(ListView):
	model=Reparto
	template_name='c_reparto_lis.html'
	paginate_by=10

class RepartoUpdate(UpdateView):
	model=Reparto
	form_class=RepartoForm
	template_name='c_reparto_reg.html'
	success_url=reverse_lazy('c_reparto_lis') 

class RepartoDelete(DeleteView):
	model=Reparto
	form_class=RepartoForm
	template_name='c_reparto_eli.html'
	success_url=reverse_lazy('c_reparto_lis')




class UsuarioDelete(DeleteView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='c_usuario_eli.html'
	success_url=reverse_lazy('c_usuario_lis')

class UsuarioUpdate(UpdateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='c_usuario_reg.html'
	success_url=reverse_lazy('c_usuario_lis') 

class UsuarioCreate(CreateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='c_usuario_reg.html'
	success_url=reverse_lazy('c_usuario_lis')

class UsuarioList(ListView):
	model=DatosPersonales
	template_name='c_usuario_lis.html'
	paginate_by=9




class RegistrarUsuario(CreateView):
	model = User 
	template_name="c_crear_user.html"
	form_class = RegistroForm
	success_url=reverse_lazy('mylogin')