from django.shortcuts import render
from django.contrib.auth.decorators import login_required, permission_required
# Create your views here.
@permission_required('inicio.es_tesorero')
def tesorero(request):
	return render(request, 'tesorero.html')