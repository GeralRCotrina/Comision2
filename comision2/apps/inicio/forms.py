from django import forms
from apps.inicio.models import DatosPersonales


class PersonaForm(forms.ModelForm):

	class Meta:
		model = DatosPersonales

		fields = ['id_datos_personales','dni','sexo',
		    'alias','fecha_nacimiento','telefono','celular','foto','id_auth_user',
		]

		labels = {
			'dni':'DNI',
			'alias':'alias',
			'sexo':'Sexo',
			'fecha_nacimiento':'fecha nacimiento',
			'telefono':'telefono',
			'celular':'Movil',
			'foto':'foto',
			'id_auth_user':'seleccione el usuario',
		}

		widgets={
			'dni':forms.TextInput(attrs={'class':'form-control'}),
			'alias':forms.TextInput(attrs={'class':'form-control'}),
			'sexo':forms.TextInput(attrs={'class':'form-control'}),
			'fecha_nacimiento':forms.DateInput(attrs={'class':'form-control','type':'date'}),
			'telefono':forms.TextInput(attrs={'class':'form-control'}),
			'celular':forms.TextInput(attrs={'class':'form-control'}),
			'foto':forms.FileInput(attrs={'class':'btn-block'}),
			'id_auth_user':forms.Select(attrs={'class':'form-control'}),
		}


from apps.inicio.models import Noticia

class NoticiaForm(forms.ModelForm):

	class Meta:
		model = Noticia

		fields = [
		    'id_noticia',
		    'titular',
		    'descripcion',
		    'fecha',
		    'foto',
		]

		labels = {
			'id_noticia':'idnoticia',
		    'titular':'titular',
		    'descripcion':'descripcion',
		    'fecha':'fecha',
		    'foto':'foto',
		}

		widgets={

			'id_noticia':	forms.TextInput(attrs={'class':'form-control'}),
			'titular':		forms.TextInput(attrs={'class':'form-control'}),
			'descripcion':	forms.TextInput(attrs={'class':'form-control'}),
			'fecha':		forms.DateTimeInput(attrs={'class':'form-control'}),
			'nombres':		forms.TextInput(attrs={'class':'form-control'}),
			'foto':			forms.TextInput(attrs={'class':'form-control'}),
		}