from django import forms
from apps.inicio.models import OrdenRiego

class OrdenRForm(forms.ModelForm):

	class Meta:
		model = OrdenRiego

		fields = ['id_orden_riego','id_reparto','id_parcela','fecha_establecida','fecha_inicio',
					'duracion','unidad','cantidad_has','importe','estado','id_comprobante']	

		labels = {
			'id_reparto':'Reparto',
			'id_parcela':'Parcela',
			'fecha_establecida':'Fecha cierre de reparto',
			'fecha_inicio':'Fecha de turno de agua',
			'duracion':'Duración #',
			'unidad':'Unidad',
			'cantidad_has':'Has a regar',
			'importe':'Importe',
			'estado':'Estado',
			'id_comprobante':'Codigo de comprobante',
		}

		widgets={	
			    'id_reparto':forms.Select(attrs={'class':'form-control'}),
			    'id_parcela':forms.Select(attrs={'class':'form-control'}),
			    'fecha_establecida':forms.DateInput(attrs={'class':'form-control','type':'date'}),
			    'fecha_inicio':forms.DateInput(attrs={'class':'form-control','type':'date'}),
			    'duracion':forms.TextInput(attrs={'class':'form-control'}),
			    'unidad':forms.TextInput(attrs={'class':'form-control'}),
			    'cantidad_has':forms.TextInput(attrs={'class':'form-control'}),
			    'importe':forms.TextInput(attrs={'class':'form-control'}),
			    'estado':forms.TextInput(attrs={'class':'form-control'}),
			    'id_comprobante':forms.TextInput(attrs={'class':'form-control'}),
		    }

