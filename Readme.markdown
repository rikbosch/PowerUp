## Integration with CI tools

PowerUp has been very carefully constructed to play nicely with CI tools.  
Powershell, psexec and robocopy pose unique challenges in this area, which we have (hopefully!) overcome.

Essentially this boils down to ensuring standard output and error are written to correctly, and that return codes are appropriate.

## Disclaimer of Influences

PowerUp is influenced by a number of previous tools.
In particular, many ideas are similar to the Nant based build system created by BBC Worldwide.

The areas where this has manifested are:  
1. The method of substituting settings from a plain text settings file into templated files.  
2. The use of psexec to execute remote scripts, and the use of "cmd.js" (originally described here http://forum.sysinternals.com/psexec-the-pipe-has-been-ended_topic10825.html) to control standard output.  

Hopefully it is clear these are fair use adoptions of ideas, not re-purposing of intellectual property.  

## What about AppHarbour?

Without a doubt, AppHarbour is a great tool for deploying simple cloud hosted websites.
By design, AppHarbour has decided to be very simple. PowerUp gives far more control.

In particular:
- You can deploy more than websites
- You can substitute virtually anything, not just app settings
- You can run arbitrary powershell scripts, not be limited to a simple git-pull scenario

Horses for courses.
In theory, there is potential to allow PowerUp to enhance AppHarbour deployments. This has not been explored in detail at this stage.