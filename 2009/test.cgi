#!/usr/bin/perl

##########################################################
# Server Test v2.1 22/August/2003
# © 2003 http://www.EZscripting.co.uk/
##########################################################
# EZscripting.co.uk © 1999 - 2004
# The scripts are available for private and commercial use.
# You can use the scripts in any website you build.
# It is prohibited to sell the scripts in any format to anybody.
# The scripts may only be distributed by EZscripting.co.uk.
# The redistribution of modified versions of the scripts is prohibited.
# EZscripting.co.uk accepts no responsibility or liability
# whatsoever for any damages however caused when using our services or scripts.
# By downloading and using this script you agree to the terms and conditions.
##########################################################
# Upload this script into the directory you are going to use for the script
# CHMOD this 755 or 777 if not public
# Run the script by typing the URL in your browser
# You should now see your PATH and URL information
##########################################################

print "Content-type: text/html\n\n";
print "<html>\n" ;
print "\n" ;
print "<head>\n" ;
print "<title>$ENV{'SERVER_NAME'} EZscripting.co.uk Server Test</title>\n" ;
print "</head>\n" ;
print "\n" ;

print "<body bgcolor=\"#FFFFFF\" text=\"#000000\" link=\"#000000\" vlink=\"#000000\" alink=\"#000000\">\n" ;
print "\n" ;

print "<center><font face=Verdana size=3><b><br>\n" ;
print "EZscripting.co.uk CGI Help Script</b></center>\n" ;

print "<font face=Verdana size=2><b><br><br>\n" ;
print "Path and URL information:</b><br><br>\n" ;
print "Your path to Perl is correct<br>\n" ;
print "Your server is running Perl version: $]<br>\n" ;
print "Your domain name is: $ENV{'SERVER_NAME'}<br>\n" ;
print "The complete system PATH to this script is: $ENV{'SCRIPT_FILENAME'}<br>\n" ;
print "The URL of this script is: http://$ENV{'SERVER_NAME'}$ENV{'SCRIPT_NAME'}<br>\n" ;

print "</body>\n" ;
print "</html>\n" ;

##########################################################
# EZscripting.co.uk © 1999 - 2004
# The scripts are available for private and commercial use.
# You can use the scripts in any website you build.
# It is prohibited to sell the scripts in any format to anybody.
# The scripts may only be distributed by EZscripting.co.uk.
# The redistribution of modified versions of the scripts is prohibited.
# EZscripting.co.uk accepts no responsibility or liability
# whatsoever for any damages however caused when using our services or scripts.
# By downloading and using this script you agree to the terms and conditions.
##########################################################

