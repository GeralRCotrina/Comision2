from django.shortcuts import render, redirect, render_to_response
from django.http import HttpResponse
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView, DeleteView, TemplateView, View
from apps.inicio.models import Reparto, Multa, DatosPersonales, Noticia, Parcela, Canal, Destajo, OrdenRiego, Caudal
from apps.canalero.forms import RepartoForm, MultaForm, DestajoForm


from apps.presidente.forms import ParcelaForm, CanalForm, NoticiaForm
from apps.inicio.forms import PersonaForm

from django.contrib.auth.decorators import login_required, permission_required

from django.contrib.auth.models import User
from apps.presidente.forms import RegistroForm
import time

 
import datetime

import pdfkit
from jinja2 import Environment, FileSystemLoader
from django.utils.dateparse import parse_date
from django.db.models import Q

class ImprimirReparto(View):

	def get(self,request,*args,**kwargs):
		idre = self.request.GET.get('id_repa')
		env = Environment(loader=FileSystemLoader("pdf", encoding = 'utf-8'))
		template = env.get_template("imprimir.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
		
		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_imprimir_ordenes (%s)",[idre])

		print(' ')
		print(' .')

		result = []
		detalles = cursor.fetchall()
		for row in detalles:
			dic = dict(zip([col[0] for col in cursor.description], row))
			result.append(dic)
		cursor.close()

		print(' ..')
		print(' ')
		ticket = 'N° -- á -- ñ -- é'

		diccionario={}
		diccionario['ticket']= ticket.encode('utf-8')		
		diccionario['ticket1']= ticket
		diccionario['ordenes']=result
		diccionario['fecha']= ' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '

		html = template.render(diccionario)
		f=open('pdf/ordenes.html','w')
		f.write(html)
		f.close()

		options = {'page-size': 'legal','margin-top':'0.0in','margin-right':'0.1in','margin-bottom':'0.9in','margin-left':'0.1in',}

		pdfkit.from_file('pdf/ordenes.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las órdenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'c_pdf_01.html',dicc)



#-----------------------------------------------------------------------------------
class ImprimirReparto1(View):

	def get(self,request,*args,**kwargs):
		idre = self.request.GET.get('id_repa')
		env= Environment(loader=FileSystemLoader("pdf"))
		template = env.get_template("imprimir.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
		
		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_imprimir_ordenes (%s)",[idre])

		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()

		diccionario={}
		diccionario['ordenes']=result
		diccionario['fecha']= ' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '

		html = template.render(diccionario)
		f=open('pdf/ordenes.html','w')
		f.write(html)
		f.close()

		options = { 
			'page-size':'A4',
			'margin-top':'0.0in',
			'margin-right':'0.1in',
			'margin-bottom':'9in',
			'margin-left':'0.1in',
			}

		pdfkit.from_file('pdf/ordenes.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las órdenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'c_pdf_01.html',dicc)




class PDF_002(View):

	def get(self,request,*args,**kwargs):
		
		env= Environment(loader=FileSystemLoader("pdf"))
		template = env.get_template("tiketD.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)

		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_rep_reparto")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		diccionario={}
		diccionario['repartos']=result
		diccionario['fecha']= ' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '
		

		html = template.render(diccionario)
		f=open('pdf/ordenes.html','w')
		f.write(html)
		f.close()

		options = { 
			'page-size':'A4',
			'margin-top':'0.1in',
			'margin-right':'0.0in',
			'margin-bottom':'0.0in',
			'margin-left':'0.0in',
			}

		pdfkit.from_file('pdf/ordenes.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las ordenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'c_pdf_01.html',dicc)

 
class PDF_001(View):

	def get(self,request,*args,**kwargs):
		
		env= Environment(loader=FileSystemLoader("pdf"))
		template = env.get_template("pdf_reparto.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)

		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_rep_reparto")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		diccionario={}
		diccionario['repartos']=result
		diccionario['fecha']= ' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '
		

		html = template.render(diccionario)
		f=open('pdf/reparto.html','w')
		f.write(html)
		f.close()

		options = { 'page-size':'A4','margin-top':'0.2in','margin-right':'0.2in',
			'margin-bottom':'0.2in','margin-left':'0.2in',	}

		pdfkit.from_file('pdf/reparto.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las ordenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'c_pdf_01.html',dicc)



#return render(request,'canalero.html')


class GrafRepC1(View):

	def get(self, request, *args, **kwargs):
		dicc={}	
		can=Canal.objects.all()
		ree=Reparto.objects.all()
		for r in ree:
			print(' r:',r)
		for c in can:
			print(' c:',c)


		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_ordenes_por_reparto_por_canal")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		
		dicc['sp']=result	
		dicc['canales']=can	
		dicc['repartos'] = ree

		return render(request,'reportes/c_graf_rep.html',dicc)














from django.db import connection, transaction	

class RepPeparto(View):

	def get(self, request, *args, **kwargs):
		cursor = connection.cursor()
		cursor.execute("CALL sp_cant_por_reparto")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		diccionario={}
		diccionario['repartos']=result
		for d in result:
			print('   - -  - >',d)
		return render(request,'reportes/c_reporte_rep.html',diccionario)


class RepCaudal2(View):

	def get(self, request, *args, **kwargs):				
		can=Canal.objects.all()
		cau=Caudal.objects.all()
		reporte_caudal = {}
		reporte_caudal['canales']=can
		reporte_caudal['caudal']=cau
		return render(request,'reportes/c_reporte_cau.html',reporte_caudal)



class RepCaudal(View):

	def get(self, request, *args, **kwargs):				
		can=Canal.objects.all()
		cau=Caudal.objects.all().order_by("-pk")
		cant_can=can.count()
		cant_cau=(cau.count()/cant_can)
		t=datetime.datetime.now()
		reporte_caudal = {}
		reporte_caudal['fecha']=datetime.datetime.now()
		reporte_caudal['canales']=can
		reporte_caudal['caudal']=cau
		reporte_caudal['cant_can']=cant_can
		reporte_caudal['cant_cau']=cant_cau
		return render(request,'reportes/c_reporte_caudal.html',reporte_caudal)





























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
		return HttpResponse(dicc)


class EstablecerHora(TemplateView):

	def get(self,request,*args,**kwargs):
		idord = self.request.GET.get('id_ord')
		diccionario ={}
		diccionario['orden']=OrdenRiego.objects.get(pk=idord)
		return render(request,'c_orden_hora.html',diccionario)

	def post(self,request,*args,**kwargs):
		fec = self.request.POST.get('fecha')
		hor = self.request.POST.get('horas')
		minu = self.request.POST.get('minutos')
		idord = self.request.POST.get('idord')
		idrepa = self.request.POST.get('idrepa')
		actu = self.request.POST.get('actu')


		dd = parse_date(fec)
		dt=datetime.datetime(year=dd.year,month=dd.month,day=dd.day)
		dt=dt+datetime.timedelta(hours=float(hor))
		dt=dt+datetime.timedelta(minutes=float(minu))

		OrdenRiego.objects.filter(pk=int(float(idord))).update(fecha_establecida=dd)
		OrdenRiego.objects.filter(pk=int(float(idord))).update(fecha_inicio=dt)

		if actu != 'on':
			CalcularHora(int(float(idord)))

		urll='../c_reparto_lis_ord/?id_repa='+str(idrepa)
		
		return redirect(urll)


def CalcularHora(idord):
	orde=OrdenRiego.objects.get(pk=idord)
	can=orde.id_parcela.id_canal.pk
	idrepa=orde.id_reparto.pk
	dicc=OrdenRiego.objects.filter(Q(id_reparto__pk=idrepa),Q(id_parcela__id_canal__pk=can),Q(estado__exact='Aprobada'))

	hr=orde.fecha_inicio
	nto=orde.id_parcela.num_toma

	for o in dicc:
		if o.pk == orde.pk:
			print(' >>> esta es::',o.id_parcela.nombre)
		else:
			if o.id_parcela.num_toma > nto:
				hr = hr+ datetime.timedelta(minutes=15)
				hr = hr+ datetime.timedelta(hours=o.duracion)
				OrdenRiego.objects.filter(pk=o.pk).update(fecha_inicio=hr)
				OrdenRiego.objects.filter(pk=o.pk).update(fecha_establecida=hr.date())





def edirtar_usuario(request,id_usuario):
	usuario=Usuario.objects.get(id=id_usuario)
	if request.method == "GET":
		form=UsuarioForm(instance=usuario)
	else:
		form = UsuarioForm(request.POST,instance=usuario)
		if form.is_valid():
			form.save()
			return redirect('lista_usuarios')
	return render(request,'registrar_usuario.html', {'form':form})



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
	success_url=reverse_lazy('RegistrarUsuario')

#mylogin