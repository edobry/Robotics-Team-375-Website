<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> <html> 
<head>
<title>Team 375: The Robotic Plague</title>
    <link rel="Stylesheet" href="data/style.css" media="all" type="text/css" />
</head>

<body>
<div class="lside">
<? 
function includeFile($file_name){

   $dir = array('./', 'articles/', 'data/', 'history/', 'images/', 'media/');    //<-- put here your website directory you want to include
   $level = array('', '/', '../', '../../');    //<-- you can add more deep level in this array
   $ini_path = array();
   
   foreach($dir as $p){
   
      foreach($level as $l){
         $file = $l.$p.$file_name;       
         if(file_exists($file)){
            include_once($file);
            return; 
         }       
      }   
   }
}

includeFile ("data/menu.html") ?>
</div>

<div class="center">
<? includeFile ("data/login.html") ?>

<h2>Welcome to the Home of Team 375: The Robotic Plague</h2>
<p><img alt="" src="images/team.jpg" align="left" class="marbor"/> Welcome to the website of The Robotic Plague. Feel free to explore our site and contact us with any questions or concerns. Thank you!</p>
<br />
<p><strong>Mission Statement</strong><br />
"To promote science and engineering in our youth today, so that they can be the scientists and engineers who create the world of tomorrow."</p>

</div>

<div class="lside">
<center><? includeFile ("data/companies.html") ?></center>
</div>

</body>
</html>
