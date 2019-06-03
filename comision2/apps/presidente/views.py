from django.shortcuts import render, redirect
from apps.inicio.models import DatosPersonales, Parcela, Canal, Noticia, AuthUser, Caudal, Reparto, OrdenRiego, Asamblea, HojaAsistencia
from apps.inicio.forms import PersonaForm
from apps.presidente.forms import ParcelaForm, CanalForm, NoticiaForm, CaudalForm, AuthForm
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView,UpdateView,DeleteView, TemplateView, View

from django.contrib.auth.decorators import login_required, permission_required

# -*- coding: utf-8 -*-

import datetime

from django.utils.dateparse import parse_date



import time
import locale
locale.setlocale(locale.LC_ALL, "")# Establecemos el locale de nuestro sistema

from django.db import connection, transaction	

 

@permission_required('inicio.es_presidente')
def presidente(request):		
	return render(request,'presidente.html')

 

class ActUsuario(View):

	def get(self, request, *args, **kwargs):
		dicc={}
		dicc['userr']= 'bacío'
		return render(request,'p_act_usu.html',dicc)

	def post(self, request, *args, **kwargs):
		dicc={}
		usuario = self.request.POST.get('usuario')
		dicc['userr']= usuario
		if AuthUser.objects.filter(username__exact=usuario).exists():
			print('__________No hay nueva contraseña aún..')
			u=AuthUser.objects.get(username__exact=usuario)
			dicc['passs']= u.password
			dicc['usuario']= usuario
			dicc['msj']= 'nda'
		else:
			dicc['msj']= 'nusr'
		return render(request,'p_act_usu.html',dicc)


class CambioUSER(View):

	def post(self, request, *args, **kwargs):
		dicc={}
		usuario = self.request.POST.get('usuario')
		nuevo_usuario=self.request.POST.get('nuevo_usuario')
		dicc['usuario']= usuario
		print(' ______________- - - > usu :',usuario,'   - -- nusu: ',nuevo_usuario)
		from django.contrib.auth.models import User
		if AuthUser.objects.filter(username__exact=usuario).exists():

			if User.objects.filter(username__exact= nuevo_usuario).exists():
				print('_____________ *.* EL NOMBRE NO ESTÁ DISPONIBLE..')
				dicc['msj'] = 'no_disp'
			else:
				print('__________ *.* SE CAMBIARÁ LA EL USUARIO..')
				u=User.objects.get(username__exact=usuario)
				u.username=nuevo_usuario
				u.save()
				dicc['usuario']= u.username
				dicc['msj']='succ1'
		else:
			print('__________ ... el usu a cambiar no existe!!!!!!!!1')	

		return render(request,'p_act_usu.html',dicc)


class CambioPASS(View):

	def post(self, request, *args, **kwargs):
		dicc={}
		usuario = self.request.POST.get('usuario')
		p1 = self.request.POST.get('nueva_contra_1')
		p2 = self.request.POST.get('nueva_contra_2')
		dicc['usuario']= usuario
		print('__________ - - - > p1 :', p1)

		if p1:
			if p1 ==  p2:
				print(' ___________CAMBIAR LA CONTRASEÑA . . . . . p1 -> ',p1,' - p2 -> ',p2)
				from django.contrib.auth.models import User

				if AuthUser.objects.filter(username__exact=usuario).exists():
					u = User.objects.get(username__exact=usuario)
					u.set_password(p1)
					u.save()
					print(' _______Se cambió la PASS de ',usuario,' por <',p1,'>')
					dicc['passs']= u.password		
					dicc['msj']= 'succ2'
					return render(request,'p_act_usu.html',dicc)
				else:
					print('_______false')
					dicc['usuario']= 'bacío'			
			else:
				dicc['msj']= 'err'
		else:
			if AuthUser.objects.filter(username__exact=usuario).exists():
				print('_________No hay nueva contraseña aún..')
				u=AuthUser.objects.get(username__exact=usuario)
				dicc['passs']= u.password
				dicc['usuario']= usuario
				dicc['msj']= 'nda'
			else:
				dicc['msj']= 'nusr'
		return render(request,'p_act_usu.html',dicc)


class RepPeparto1(View):

	def get(self, request, *args, **kwargs):
		re=Reparto.objects.all()
		reporte_reparto = {}
		reporte_reparto['repartos']=re
		for r in re:
			reporte_reparto['co',r.id_reparto]=OrdenRiego.objects.filter(id_reparto=r.id_reparto).count()
			print('    -   -  >  ',r.id_reparto,'  - -  ',reporte_reparto['co',r.id_reparto])

		return render(request,'reportes/p_reporte_rep.html',reporte_reparto)






class AsambReg(View):
	def get(self, request, *args, **kwargs):
		return render(request,'asamblea/p_asamb_reg.html')

	def post(self,request,*args,**kwargs):
		desc =  self.request.POST.get('descripcion_asamb')
		fec =  self.request.POST.get('fecha_asamb')
		hor =  self.request.POST.get('hora_asamb')
		tipo =  self.request.POST.get('tipo_asamb')
		HorArr = hor.split(':')

		fech = parse_date(fec)
		dt=datetime.datetime(year=fech.year,month=fech.month,day=fech.day)
		dt=dt+datetime.timedelta(hours=float(HorArr[0]))
		dt=dt+datetime.timedelta(minutes=float(HorArr[1]))
		dtr =  datetime.datetime.now()

		asamb=Asamblea(tipo=tipo,descripcion=desc,fecha_registro=dtr,fecha_asamblea=dt,estado=1)
		asamb.save()
		return render(request,'asamblea/p_asamb_reg.html',{'msj':'Se guardó correctamente.'})


class AsambLis(View):
	def get(self, request, *args, **kwargs):
		ListAsamb = Asamblea.objects.all()
		return render(request,'asamblea/p_asamb_lis.html',{'asambleas':ListAsamb})

class AsambEdi(View):
	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('id_asamb')
		asamb = Asamblea.objects.get(pk=pka)
		return render(request,'asamblea/p_asamb_edi.html',{'msj':'editando asamblea.','asamb':asamb})

	def post(self,request,*args,**kwargs):
		pka =  self.request.POST.get('id_asamb')
		desc =  self.request.POST.get('descripcion_asamb')
		fec =  self.request.POST.get('fecha_asamb')
		hor =  self.request.POST.get('hora_asamb')
		tipo =  self.request.POST.get('tipo_asamb')
		HorArr = hor.split(':')
		FecArr = fec.split('/')

		fech = parse_date(fec)
		dt=datetime.datetime(year=int(FecArr[2]),month=int(FecArr[1]),day=int(FecArr[0]))
		dt=dt+datetime.timedelta(hours=float(HorArr[0]))
		dt=dt+datetime.timedelta(minutes=float(HorArr[1]))
		Asamblea.objects.filter(pk=int(float(pka))).update(tipo=tipo,descripcion=desc,fecha_asamblea=dt,estado=1)
		ListAsamb = Asamblea.objects.all()
		return render(request,'asamblea/p_asamb_lis.html',{'msj':'Se editó correctamente.','asambleas':ListAsamb})

class AsambIni(View):
	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('id_asamb') 
		asamb = Asamblea.objects.get(pk=pka)
		parc = Parcela.objects.all()

		if asamb.tipo == 'General':
			
			hr = time.strftime("%I:%M:%S")
			hr = "2000-01-01 00:00:01"
			for p in parc :
				Hasis = HojaAsistencia(id_asamblea=asamb,id_auth_user=p.id_auth_user,estado="0" ,hora=hr)
				#Hasis.save()

			lstHAsis = HojaAsistencia.objects.filter(id_asamblea=asamb)
			return  render(request,'asamblea/p_asamb_asis.html',{'msj':'CREADA 1','lstHAsis':lstHAsis})


		elif asamb.tipo == 'Simple':
			return  render(request,'asamblea/p_asamb_asis.html',{'msj':'CREADA 2'})
		else :
			print("      >> ERR")
			return  render(request,'asamblea/p_asamb_asis.html',{'msj':'ERR'})

		return render(request,'asamblea/p_asamb_asis.html',{'msj':'VAMOS A INICIAR','pka':pka})











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
		return render(request,'reportes/p_reporte_rep.html',diccionario)



class RepCaudal2(View):

	def get(self, request, *args, **kwargs):				
		can=Canal.objects.all()
		cau=Caudal.objects.all()
		reporte_caudal = {}
		reporte_caudal['canales']=can
		reporte_caudal['caudal']=cau
		return render(request,'reportes/p_reporte_cau.html',reporte_caudal)



class RepCaudal(View):

	def get(self, request, *args, **kwargs):				
		can=Canal.objects.all()
		cau=Caudal.objects.all().order_by("-pk")
		cant_can=can.count()
		cant_cau=(cau.count()/cant_can)
		t=datetime.now()
		reporte_caudal = {}
		reporte_caudal['fecha']=datetime.now()
		reporte_caudal['canales']=can
		reporte_caudal['caudal']=cau
		reporte_caudal['cant_can']=cant_can
		reporte_caudal['cant_cau']=cant_cau
		return render(request,'reportes/p_reporte_caudal.html',reporte_caudal)



class CaudalCreate(TemplateView):	

	def get(self, request, *args, **kwargs):
		dicc={}
		can = Canal.objects.all()
		dicc['canales']=can
		return render(request,'p_caudal_reg.html',dicc)

	def post(self, request, *args, **kwargs):
		can=Canal.objects.all()
		fecha = self.request.POST.get('fecha')		
		for ca in can:
			niv=self.request.POST.get(str(ca.id_canal))
			cau=Caudal(id_canal=ca,fecha=fecha,nivel=niv,descripcion='Descripción')
			cau.save()
		dicc={}
		dicc['mensaje']='Registro de caudal hecho correctamente'
		return render(request,'p_caudal_reg.html',dicc)


def ListaE(request):
	auth = AuthUser.objects.all()
	datos = DatosPersonales.objects.all()
	diccionario = {}
	diccionario["auth"] = auth
	diccionario["datos"] = datos
	return render(request,'listae.html',diccionario)



class CaudalList(ListView):
	model=Caudal
	template_name='p_caudal_lis.html'
	paginate_by=9

class CaudalDelete(DeleteView):
	model=Caudal
	form_class=CaudalForm
	template_name='p_caudal_eli.html'
	success_url=reverse_lazy('p_caudal_lis')




 

class NoticiaCreate(CreateView):
	model=Noticia
	form_class=NoticiaForm
	template_name='p_noticia_reg.html'
	success_url=reverse_lazy('p_noticia_lis')

class NoticiaList(ListView):
	model=Noticia
	template_name='p_noticia_lis.html'
	paginate_by=9

class NoticiaUpdate(UpdateView):
	model=Noticia
	form_class=NoticiaForm
	template_name='p_noticia_reg.html'
	success_url=reverse_lazy('p_noticia_lis') 

class NoticiaDelete(DeleteView):
	model=Noticia
	form_class=NoticiaForm
	template_name='p_noticia_eli.html'
	success_url=reverse_lazy('p_noticia_lis')



 



class ParcelaCreate(CreateView):
	model=Parcela
	form_class=ParcelaForm
	template_name='p_parcela_reg.html'
	success_url=reverse_lazy('p_parcela_lis')

class ParcelaList(ListView):
	model=Parcela
	template_name='p_parcela_lis.html'
	paginate_by=20

class ParcelaUpdate(UpdateView):
	model=Parcela
	form_class=ParcelaForm
	template_name='p_parcela_reg.html'
	success_url=reverse_lazy('p_parcela_lis') 

class ParcelaDelete(DeleteView):
	model=Parcela
	form_class=ParcelaForm
	template_name='p_parcela_eli.html'
	success_url=reverse_lazy('p_parcela_lis')



class CanalCreate(CreateView):
	model=Canal
	form_class=CanalForm
	template_name='p_canal_reg.html'
	success_url=reverse_lazy('p_canal_lis')

class CanalList(ListView):
	model=Canal
	template_name='p_canal_lis.html'
	paginate_by=9

class CanalUpdate(UpdateView):
	model=Canal
	form_class=CanalForm
	template_name='p_canal_reg.html'
	success_url=reverse_lazy('p_canal_lis') 

class CanalDelete(DeleteView):
	model=Canal
	form_class=CanalForm
	template_name='p_canal_eli.html'
	success_url=reverse_lazy('p_canal_lis')




class DatosDelete(DeleteView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='p_usuario_eli.html'
	success_url=reverse_lazy('p_usuario_lis')

class DatosUpdate(UpdateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='p_usuario_reg.html'
	success_url=reverse_lazy('p_usuario_lis') 

class DatosCreate(CreateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='p_usuario_reg.html'
	success_url=reverse_lazy('p_usuario_lis')

class DatosList(ListView):
	model=DatosPersonales
	template_name='p_usuario_lis.html'
	paginate_by=9




class AuthList(ListView):
	model=AuthUser
	template_name='p_auth_lis.html'



class BuscarAuthList(TemplateView):

	def post(self,request,*args,**kwargs):
		buscar = request.POST['buscar']
		auths=AuthUser.objects.all()
		dicc = {"personas":auths}		
		return render(request,'p_auth_lis.html',dicc)
