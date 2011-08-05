# Status

PowerUp is already been used internally by Affinity ID to release projects through to Live.
This includes file deployment, website creation with SSL, and Umbraco Courier.

# QuickStart

(This quick start will work on any Windows installation with Powershell and IIS 7+ installed)

- Git clone or download to any local directory
- Install the IIS Powershell snapin http://learn.iis.net/page.aspx/429/installing-the-iis-70-powershell-snap-in/
- Run build_package_deploy_local.bat to see a two versions (a trunk and branch) of a typical website built and deployed to localhost.
- Browse to http://localhost:9000 and https://localhost:9001 to see the http/https version of trunk
- Browse to http://localhost:10000 and https://localhost:10001 to see the http/https version of trunk


# Overview

## Basics

PowerUp is a build and deployment framework, written on top of Powershell and Psake.

The philosophy of PowerUp is based on the concept of deployment through "unremarkable" zipped packages of files. Rooted in the xcopy deployment mindset, it simply adds the plumbing required to make one package deployable in a number of different environments. It also provides the framework and bundled tools to enable the configuration of Windows servers.

## Packages

In contrast to other types of deployment packages (msis, installshield etc), PowerUp packages are just simple zip files. Within these packages are the files from your solution, supporting PowerUp files (mostly PowerShell script files, cmdlets, and some 3rd party tools), and a Psake Powershell script you write (which describes what must happen during the deployment).  

## Settings

Although packages are environment neutral, they also contain a settings file. This files lays out in plain text a set of key/value pairs describing the configuration of each environment. Not only are these settings available within your scripts, they can also be used to substitute into any plain text file.

## Deployment scripts

As the deployment script is written in Powershell, there is virtually no limit to what can be done. The capabilities currently bundled within PowerUp include:  

- Creating websites, app pools, virtual directories. Includes ssl administration.  
- Copying files quickly and robustly with robocopy  
- Deploying with Umbraco Courier  

But of course, this is just the beginning. As PowerShell is the first class scripting environment in Windows, you are free to use any script, cmdlet or plain executable you choose.   

In the near future, we expect to add support for:  

- Database activities, such as backing up/restoring  
- Administration of scheduled tasks  
- Installation of windows services  

## Source structure

- The files in the _powerup directory is the core PowerUp framework that should be put in the root of the source tree your will be deploying. This can be done (for example) with an svn extern. Any changes to the _powerup folder should be treated as a fork or PowerUp. If you don't alter this directory, you should be able to upgrade powerup at any time.
- The directory SimpleWebsite is the example website being deployed.
- The file main.build is a Nant file the describes which files need to be added to the package. The nant file included within main.build (common.build) takes care of compiling your solution, adding the required PowerUp files, and zipping everything up.
- The file deploy.ps1 (which is a psake file) describes what needs to be done to deploy your package to a server. This script can assume it is running on the destination server itself (so all paths are local etc)
- The file settings.txt .
- The directory _templates, used to create templated versions of any files that require values substituted into them (see below for more details)
- The files build_package.bat and build_package_deploy_local.bat are simply convenience batch files.

## How to Integrate Into a Project

For most deployments, only 4 things need to be created:  

- The nant script main.build, describing how to build and what files are to be contained in the package.  
- A plain text file (settings.txt) with a list of configuration settings per environment  
- A set of templates (typically web.configs) with placeholders for the defined settings (_templates folder)
- A Powershell file (deploy.ps1), to be executed on the destination machine  

# FAQs

## Could I use PowerUp for projects not written in .Net?

Yes. By default the helper Nant script assumes a single .Net solution file. But this can easily be replaced with any set of build steps.

## Why Nant for building packages (and not MSBuild/PowerShell etc)?

Nant is designed to build .Net solutions, and does so very well. It is exceptionally expressive when it comes to file copying, which creates a nice declarative syntax with which to construct packages. It is not so strong for performing deployments, due to its inexpressiveness as a general purpose scripting language, and its restriction to calling nant tasks and command line executables. That is why both Nant and Powershell are used with PowerUp.

Despite this, any other tool could be used to construct the packages (as long as they end up with the same structure). In fact, packages can even be created by hand, if so inclined.

## Why Not Use Web Deployment Projects/Configuration Transformations?

There are couple of reasons behind this decision:  

- You need to build for each environment  
- You can only use if for xml config files  
- You can only easily use it for web.config  
- It hides the settings within an xml transform, which prevents the centralisation of settings into a single, easy to read, file  
- It is .Net only  

Having said that, it would be possible to adapt PowerUp to most configuration substitution schemes. The only restriction is that one package must contain everything required for all environments, without rebuilding.

## Why use psexec when there is PowerShell Remoting?

Psexec is used for two reasons. One is that it is very simple and reliable. Secondly, we experienced (fairly typical) issues setting up Powershell Remoting in our environment.  

Contributions that incorporate powershell remoting would be welcome.

## What Permissions are Required?

Due to the nature of most deployments, the permissions of the executing account have to be fairly elevated. Local admin would be required for most deployments. At the very least, you need to be local admin on the destination server for psexec to work.

Obviously, if any scripts attempt to manipulate (for example) Active Directory, then domain admin rights may be required.

## Integration with CI tools

PowerUp has been very carefully constructed to play nicely with CI tools. Our CI tool of choice is currently Bamboo, but TeamCity etc should function well.    
Powershell, psexec and robocopy pose unique challenges in this area, which we have been overcome.

Essentially these challenges amount to ensuring standard output and error are written to correctly, and that return codes are appropriate.

## How Can I Extend PowerUp?

We expect extension will mainly come from new cmdlets. There are a few ways this can be done:  
- Write new cmdlets, and make a pull request to contribute back to PowerUp. It would be ideal for PowerUp to start being a repository of the very best deployment related cmdlets. These cmdlets will be almost always be useable by anyone, even if not throw the PowerUp framework.  
- Use cmdlets you find elsewhere, imported only in your own psake deploy file.  
- Write your own proprietary cmdlets, which never have to leave your organisation.  

The core PowerUp framework should not need to change as much as the deployment cmdlets.

## What about Azure?

I'm no expert. But as long as you can copy zip files and can run Powershell, any Windows environment should be supported.

## What about AppHarbour?

Without a doubt, AppHarbour is a great tool for deploying simple cloud hosted websites.
By design, AppHarbour has decided to be very simple. PowerUp gives far more control.

Particular difference include:  
- You can deploy more than websites (services, desktop applications)   
- You can deploy code in any language (as long as it runs on Windows)    
- You can substitute any value within any text file, not just app settings  
- You can run arbitrary powershell scripts  
- Deployments can be made from more than a single git repo    

This is very much a case of horses for courses.

In theory, there is potential to allow PowerUp to enhance AppHarbour deployments. This has not been explored in detail at this stage.


# Appendix

## Disclaimer of Background Influences

PowerUp is influenced by a number of previous tools, including proprietary ones.
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
