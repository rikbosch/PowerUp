# Status

PowerUp is already been used internally by Affinity ID to release projects through to Live.
This includes file deployment, website creation with SSL, and Umbraco Courier.

The first version should be available here in early August 2011.

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
1. Creating websites, app pools, virtual directories. Includes ssl administration.  
2. Copying files quickly and robustly with robocopy  
3. Deploying with Umbraco Courier  

But of course, this is just the beginning. As PowerShell is the first class scripting environment in Windows, you are free to use any script, cmdlet or plain executable you choose.   

In the near future, we expect to add support for:  
1. Database activities, such as backing up/restoring  
2. Administration of scheduled tasks  
3. Installation of windows services  

## How to Integrate Into a Project

For most deployments, only 4 things need to be created:  

1. A Nant script, describing how to build and what files are to be contained in the package.  
2. A plain text file with a list of configuration settings per environment  
3. A set of templates (typically web.configs) with placeholders for the defined settings  
4. A Powershell file, to be executed on the destination machine  

# FAQs

## Could I use PowerUp for projects not written in .Net?

Yes. By default the helper Nant script assumes a single .Net solution file. But this can easily be replaced with any set of build steps.

## Why Nant for building packages (and not MSBuild/PowerShell etc)?

Nant is designed to build .Net solutions, and does so very well. It is exceptionally expressive when it comes to file copying, which creates a nice declarative syntax with which to construct packages. It is not so strong for performing deployments, due to its inexpressiveness as a general purpose scripting language, and its restriction to calling nant tasks and command line executables. That is why both Nant and Powershell are used with PowerUp.

Despite this, any other tool could be used to construct the packages (as long as they end up with the same structure). In fact, packages can even be created by hand, if so inclined.

## Why Not Use Web Deployment Projects/Configuration Transformations?

There are couple of reasons behind this decision:  
1. You need to build for each environment  
2. You can only use if for xml config files  
3. You can only easily use it for web.config  
4. It hides the settings within an xml transform, which prevents the centralisation of settings into a single, easy to read, file  

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
1. The idea of substituting values from a plain text settings file into template files.  
2. The use of psexec to execute remote scripts, and the use of "cmd.js" (originally described here http://forum.sysinternals.com/psexec-the-pipe-has-been-ended_topic10825.html) to control standard output.  

The intention is that these are fair-use adoptions of ideas.

## Alternatives

Bounce: https://github.com/refractalize/bounce. 

The main difference is that Bounce is C# based. We decided on Powershell for its unparalleled breath of support in Windows, flexibility across languages, and to provide a very low barrier for entry. Bounce has other strengths - more maturity, clearer semantics and testability. There is future potential for the use of Bounce within PowerUp. 

