## Why use psexec when there is PowerShell Remoting?

Psexec was used for two reasons. One is that it is very simple and reliable. Secondly, because powershell remoting had issues in our environment that proved difficult to overcome.  

Contributions that incorporate powershell remoting would be welcome.

## Integration with CI tools

PowerUp has been very carefully constructed to play nicely with CI tools.  
Powershell, psexec and robocopy pose unique challenges in this area, which we have been overcome.

Essentially these challenges amount to ensuring standard output and error are written to correctly, and that return codes are appropriate.

## Disclaimer of Influences

PowerUp is influenced by a number of previous tools, including proprietary ones.
In particular, many ideas are similar to the Nant based build system used by BBC Worldwide.

The areas where this influence shows are in particular:  
1. The method of substituting values from a plain text settings file into template files.  
2. The use of psexec to execute remote scripts, and the use of "cmd.js" (originally described here http://forum.sysinternals.com/psexec-the-pipe-has-been-ended_topic10825.html) to control standard output.  

The intention is that these are fair-use adoptions of ideas.

## What about AppHarbour?

Without a doubt, AppHarbour is a great tool for deploying simple cloud hosted websites.
By design, AppHarbour has decided to be very simple. PowerUp gives far more control.

Particular difference include:  
- You can deploy more than websites (services, desktop applications)   
- You can deploy code in any language (as long as it runs on Windows)    
- You can substitute virtually anything, not just app settings  
- You can run arbitrary powershell scripts
- Deployments can be made from more than a single git repo    

This is very much a case of horses for courses.

In theory, there is potential to allow PowerUp to enhance AppHarbour deployments. This has not been explored in detail at this stage.