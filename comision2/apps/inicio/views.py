
from django.shortcuts import render, redirect, HttpResponse
from django.contrib.auth.models import User
from apps.presidente.forms import RegistroForm


from django.views.generic import CreateView
from django.urls import reverse_lazy

from django.contrib.auth import authenticate, login

from django.contrib import messages


"""

def login(request):
    if request.method == 'POST':
        form = AuthenticationForm(request.POST)
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(username=username, password=password)

        if user is not None:
            if user.is_active:
                auth_login(request, user)
                return redirect('index')
        else:
            messages.error(request,'username or password not correct')
            return redirect('login')

    else:
        form = AuthenticationForm()
    return render(request, 'todo/login.html', {'form': form})

"""
def mylogin(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            #aqui va la lógica de usuario
            if user.has_perm('inicio.es_canalero'):
                return redirect('canalero')
            elif user.has_perm('inicio.es_presidente'):
                return redirect('presidente')
            elif user.has_perm('inicio.es_vocal'):
                return redirect('vocal')
            elif user.has_perm('inicio.es_tesorero'):
                return redirect('tesorero')       
            else:
                return redirect('usuario')
        else:
            messages.error(request,'Datos incorrectos!!')
            return render(request, 'loginn.html')
    else:
        return render(request, 'loginn.html')



#datos del USER
class RegistrarUsuario(CreateView):
	model = User 
	template_name="crear_user.html"
	form_class = RegistroForm
	success_url=reverse_lazy('p_auth_lis')

  
def index(request):
	return render(request,'index.html')
"""
def mylogin(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            #aqui va la lógica de usuario
            if user.has_perm('inicio.es_canalero'):
                return redirect('canalero')
            elif user.has_perm('inicio.es_presidente'):
                return redirect('presidente')
            elif user.has_perm('inicio.es_vocal'):
                return redirect('vocal')
            elif user.has_perm('inicio.es_tesorero'):
                return redirect('tesorero')       
            else:
                return redirect('usuario')
        else:
            return render(request, 'loginn.html')
    else:
        return render(request, 'loginn.html')


"""