from django import forms
from apps.inicio.models import Reparto, Multa, MultaAsistencia, MultaLimpia, MultaOrden, Destajo
from django.forms import DateTimeField

class RepartoForm(forms.ModelForm):

	class Meta:
		model = Reparto
		
		fields = ['id_reparto','descripcion','tipo','fecha_reparto',]	

		labels = {
			'descripcion':'Breve descripción',
			'tipo':'Tipo de reparto',
			'fecha_reparto':'Fecha de entrega de órdenes (dd/mm/aa hh:mm)',
		}

		widgets={	
				'descripcion':forms.Textarea(attrs={'class':'form-control'}),
			    'tipo':forms.Select(attrs={'class':'form-control'}),
			    'fecha_reparto':forms.DateTimeInput(format=["%d %b %Y %H:%M:%S %Z"],attrs={'class':'form-control','placeholder':'dd/mm/aa hh:mm'})
		    }





class DestajoForm(forms.ModelForm):

	class Meta:
		model = Destajo

		fields = ['id_destajo','id_canal','id_parcela','tamano','num_orden','descripcion']	

		labels = {
			'id_canal':'Seleccione el canal en el que se ubica',
			'id_parcela':'La parcela a la que corresponde',
			'tamano':'tamaño en metros',
			'num_orden':'númer de destajo en el canal',
			'descripcion':'Descripción'
		}

		widgets={	
				'id_canal':forms.Select(attrs={'class':'form-control'}),
			    'id_parcela':forms.Select(attrs={'class':'form-control'}),
			    'tamano':forms.TextInput(attrs={'class':'form-control'}),
			    'num_orden':forms.TextInput(attrs={'class':'form-control'}),
			    'descripcion':forms.TextInput(attrs={'class':'form-control'}),
		    }


class MultaForm(forms.ModelForm):

	class Meta:
		model = Multa

		fields = ['id_multa','concepto','fecha','estado','tipo',]	

		labels = {
			'concepto':'Concepto de la multa',
			'fecha':'Fecha de emisión',
			'estado':'Estado de la Multa',
			'tipo':'tipo de la Multa',
		}

		widgets={	
			    'tipo':forms.TextInput(attrs={'class':'form-control'}),
			    'concepto':forms.Textarea(attrs={'class':'form-control'}),
			    'fecha':forms.DateInput(attrs={'class':'form-control','type':'date'}),
			    'estado':forms.TextInput(attrs={'class':'form-control'}),
			    'tipo':forms.TextInput(attrs={'class':'form-control'}),
		    }


class MultaAsistenciaForm(forms.ModelForm):

	class Meta:
		model = MultaAsistencia

		fields=['id_multa_asistencia','id_multa','id_hoja_asistencia']

		labels = {
		'id_multa':'Multa',
		'id_hoja_asistencia':'Asistencia a multar',
		}

		widgets={
		'id_multa':forms.Select(attrs={'class':'form-control'}),
		'id_hoja_asistencia':forms.Select(attrs={'class':'form-control'}),
		}


class MultaLimpiaForm(forms.ModelForm):

	class Meta:
		model = MultaLimpia

		fields=['id_multa_limpia','id_multa','id_det_limpia']

		labels = {
		'id_multa':'Multa',
		'id_det_limpia':'Destajo a Multar',
		}

		widgets={
		'id_multa':forms.Select(attrs={'class':'form-control'}),
		'id_det_limpia':forms.Select(attrs={'class':'form-control'}),
		}


class MultaOrdenForm(forms.ModelForm):

	class Meta:
		model = MultaOrden

		fields=['id_multa_orden','id_multa','id_orden']

		labels = {
		'id_multa':'Multa',
		'id_orden':'Orden a Multar',
		}

		widgets={
		'id_multa':forms.Select(attrs={'class':'form-control'}),
		'id_orden':forms.Select(attrs={'class':'form-control'}),
		}
