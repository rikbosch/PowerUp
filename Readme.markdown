## Introduction

PowerUp is a build and deployment framework, written on top of Powershell and Psake.  

PowerUp prefers to be simple, low obligation and assumes very little. 
There is nothing to be installed, with the only dependency being Powershell. 

It is designed for people that rightly think deployments really shouldn't be complicated. 

The philosophy of PowerUp is based on the concept of deployment through "unremarkable" zipped packages of files. 
Rooted in the xcopy deployment mindset, it simply adds the plumbing required to make one package deployable in a number of different environments.
It also bundles convenient  tools to enable the configuration of Windows servers (ie, create websites etc).

# Status

PowerUp is already being regularly used internally by Affinity ID to release projects through to production.  
This includes file deployment, website creation (with SSL), App Fabric, MSMQ, Amazon Web Services, database migrations, fonts and Umbraco Courier revision publications.  

The basic framework should now be fairly stable.
Different deployment cmdlets are being actively developed all the time. Coming up are:  
- Database admin, such as backing up/restoring and migrations   
- Administration of scheduled tasks and windows services  
- "Rolling" no-downtime website deployments, in the style of capistrano
- Simplified, declarative syntax for common website deployments  

Other aspects that may make an appearance in the future are:  
- SSRS maintenance  
- Sharepoint administration  
- Alertnative setting formats (eg YML)  

Follow @powerupdeploy on Twitter to keep up to date with progress.
Also, I will be posting a series a blog entries at http://llevera.wordpress.com/2011/09/04/building-powerup-the-exclusive-behind-the-scenes-making-of-mini-series/ which will detail the design and use of PowerUp.

# QuickStart

This quick start will work on any Windows installation with Powershell and IIS 7+ installed.
It demonstrates the build and automated deployment of a simple Asp.Net web application. The best way to understand PowerUp is to run it and trace through what is happening. 

To run, do the following:  

- Git clone or download to any local directory
- Install the IIS Powershell snapin http://learn.iis.net/page.aspx/429/installing-the-iis-70-powershell-snap-in/
- Run build_package_nant_deploy_local.bat to deploy a typical website to localhost
- Browse to http://localhost:9000 

This quickstart can be found in more detail here: http://llevera.wordpress.com/2011/10/01/powerup-quickstart/

# Disclaimer of Background Influences

PowerUp is influenced by a number of existing tools, including proprietary ones.
In particular, many ideas are similar to the Nant based build system used by BBC Worldwide.

The aspects where this influence shows are, in particular:  
- The idea of substituting values from a plain text settings file into template files.  
- The use of psexec to execute remote scripts, and the use of "cmd.js" (originally described here http://forum.sysinternals.com/psexec-the-pipe-has-been-ended_topic10825.html) to control standard output.  

The intention is that these are fair-use adoptions of ideas.

## Alternatives

### Bounce
https://github.com/refractalize/bounce. 

The main difference is that Bounce is C# based. We decided on Powershell for its unparalleled breath of support in Windows, flexibility across languages, and to provide a very low barrier for entry. Bounce has other strengths - more maturity, clearer semantics and testability. There is future potential for the use of Bounce within PowerUp. 

### UppercuT
http://code.google.com/p/uppercut/

Largely a build and test running framework, not a deployment one.
In theory, UppercuT could be used as an alternative to straight Nant to create PowerUp packages.
It does, however, build a package per environment which goes against the environment neutrality built into PowerUp packages.

### Pstrami
https://github.com/jhicks/pstrami

Has an attractively closer similarity to capistrano in terms of the script syntax, but has less functionality overall.