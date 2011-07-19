# Overview

## Basics

PowerUp is a build and deploy framework, written on top of Powershell and Psake.

The philosophy of PowerUp is built on top the concept of deployment through "unremarkable" zipped packages of files. Rooted in the xcopy deployment mindset, it simply adds the plumbing required to make one package deployable in a number of different environments.

## Packages

In contrast to other types of deployment packages (msi's installshield etc), these packages are just simple zip files. Within these packages are the files from your solution, supporting PowerUp files (mostly PowerShell script files, cmdlets, and some 3rd party tools), and a Psake Powershell script you write, describing what must happen during the deploy.  

## Settings

Although packages are environment neutral, they also contain a settings file. This files lays out in plain text a set of key/value pairs describing the configuration of each environment. Not only are these settings available within your Psake script, they can also be used to substitute into any plain text file you choose.

## Deployment scripts

As this script is Powershell, there is virtually no limit to what can be done. The capabilities bundled with PowerUp include:  
1. Creating websites, app pools, virtual directories  
2. Copying files quickly and robustly with robocopy  
3. Deploying with Umbraco Courier  

But of course, this is just the beginning. As PowerShell is the first class scripting environment in Windows, you are free to use any script, cmdlet or plain executable you choose. 

In the near future, we expect to add support for:
1. Database activities, such as backing up/restoring  
2. Administration of scheduled tasks
3. Installation of windows services

## How to Integrate Into a Project

So for most deployments, only 4 things need to be created:  

1. A Nant script, describing how to build and what files are to be contained in the package.
2. A plain text file with a list of configuration settings per environment
3. A set of templates (typically web.config etc) with placeholders for the defined settings
4. A Powershell file, to be executed on the destination machine


# FAQs

## Could I use PowerUp for projects not written in .Net??

Yes. By default the Nant helper scripts assume a single .Net solution file. But this can easily be replaced with any set of build steps.

## Why Nant, and not MSBuild/PowerShell?

Nant is designed to build .Net solutions, and does so very well. It is exceptionally expressive when it comes to file copying, which creates a nice declarative syntax with which to construct packages. It is not so strong for performing deployments, due to its inexpressiveness as a general purpose scripting language. That is why both Nant and Powershell are used.

Despite this, any other tool could be used to construct the packages (as long as they end up with the same structure). In fact, packages can even be created by hand, if so inclined.

## Why use psexec when there is PowerShell Remoting?

Psexec was used for two reasons. One is that it is very simple and reliable. Secondly, because powershell remoting had issues in our environment that proved difficult to overcome.  

Contributions that incorporate powershell remoting would be welcome.

## Integration with CI tools

PowerUp has been very carefully constructed to play nicely with CI tools.  
Powershell, psexec and robocopy pose unique challenges in this area, which we have been overcome.

Essentially these challenges amount to ensuring standard output and error are written to correctly, and that return codes are appropriate.

## What about Azure?

I'm no expert. But as long as you can copy zip files and can run Powershell, any Windows environment should work.

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

## Disclaimer of Influences

PowerUp is influenced by a number of previous tools, including proprietary ones.
In particular, many ideas are similar to the Nant based build system used by BBC Worldwide.

The areas where this influence shows are in particular:  
1. The method of substituting values from a plain text settings file into template files.  
2. The use of psexec to execute remote scripts, and the use of "cmd.js" (originally described here http://forum.sysinternals.com/psexec-the-pipe-has-been-ended_topic10825.html) to control standard output.  

The intention is that these are fair-use adoptions of ideas.
