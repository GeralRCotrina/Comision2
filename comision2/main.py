import pdfkit
from jinja2 import Environment, FileSystemLoader

import time
import os
env= Environment(loader=FileSystemLoader("pdf"))
template = env.get_template("pdf_base.html")

path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)

usuario={
		'nombre':'Geral R Cotrina',
		'reparto':1,
		'canal':'Ramal 1',
		'usuario':'Maria LM',
		'id_orden':7,
		'toma':2,
		'fecha':'3-11-18',
		'hectareas':2,
	}


html = template.render(usuario)
f=open('pdf/file.html','w')
f.write(html)
f.close()

options = {
	'page-size':'A4',
	'margin-top':'0.2in',
	'margin-right':'0.2in',
	'margin-bottom':'0.2in',
	'margin-left':'0.2in',
}

pdfkit.from_file('pdf/file.html', 'pdf/file.pdf',options=options, configuration=config)


"""
dfkit.from_file('file.html', 'pdf/file.pdf', configuration=config)

pdfkit.from_url('http://google.com', 'MyPDFgoogle.pdf', configuration=config)
pdfkit.from_string(html, 'MyPDF.pdf', configuration=config)
f=open('nuevo_html.html','w')
f.write(html)
f.close()
"""

 