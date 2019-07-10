function SeePassword(){
	var eye = document.getElementById("eye-password");
	var passw = document.getElementById("password");

	var classEye = eye.className.split(" ");
	if(classEye[1] == "fa-eye"){
		eye.classList.remove("fa-eye");
		eye.classList.add("fa-eye-slash");
		passw.type = "text";
	}else{
		eye.classList.remove("fa-eye-slash");
		eye.classList.add("fa-eye");
		passw.type = "password";
	}
}

 