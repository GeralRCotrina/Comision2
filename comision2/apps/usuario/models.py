"""from django.db import models


from apps.canalero.models import Reparto
# Create your models here.


class Usuario(models.Model):
	ApellidoPaterno=models.CharField(max_length=35)
	ApellidoMaterno=models.CharField(max_length=35)
	Nombres=models.CharField(max_length=35)
	DNI=models.CharField(max_length=8)
	FechaNacimiento=models.DateField()
	SEXOS=(('F','Femenino'),('M','Masculino'))
	Sexo=models.CharField(max_length=1,choices=SEXOS, default='M')
	telefono=models.CharField(max_length=9)
	email=models.EmailField()


	def NombreCompleto(self):
		cadena="{0} {1}, {2}"
		return cadena.format(self.ApellidoPaterno,self.ApellidoMaterno, self.Nombres)
		
	def __str__(self):
		return self.NombreCompleto()



class Orden(models.Model):
	Usuario=models.ForeignKey(Usuario,null=False,blank=False,on_delete=models.CASCADE)
	Reparto=models.ForeignKey(Reparto,null=False,blank=False,on_delete=models.CASCADE)#ManyToManyField(Reparto,null=False,blank=False)
	FechaOrden=models.DateTimeField(auto_now_add=True)

	def __str__(self):
		cadena="{0} => {1}"
		return cadena.format(self.Usuario,self.Reparto)

class Parcela(models.Model):
	NombreP =models.CharField(max_length=50)
	Ubicacion =models.CharField(max_length=100)
	NumeroToma=models.CharField(max_length=3)
	HasTotal=models.CharField(max_length=3)
	HasSembradas=models.CharField(max_length=3)
	Usuario=models.ForeignKey(Usuario,null=False,blank=False,on_delete=models.PROTECT)

	def __str__(self):
		cadena="{0} ,{1} en {2}"
		return cadena.format(self.Usuario,self.NombreP,self.Ubicacion)

"""


	