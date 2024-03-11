## Pong in assembly and C
A classic pong game implemented using functionality provided by the raylib library. When writing the project, I decided that it will be a lot easier to first write the derired code in C and then simply translate it to assembly, instead of writing everything from zero. Although, since then I have significantly refined the assembly version, both programs are still in the repo, along with ample comments. Thanks to this, both programs are easily comparable side-by-side.

## Setup on Apple silicon macs
The project is written in x86_64 assembly and can be ran on M series macs through rosetta. To do it however, we first need to download a separate brew version for installing x86 packages: <br/>
```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"``` <br/>
And then, download the raylib for x86:<br/>
```arch -x86_64 /usr/local/homebrew/bin/brew install raylib```

## To build
```arch -x86_64 zsh ./build.sh``` 

## To run assembly version
```./.build/bin```

## To run C version
```./.build/pong```

## Total time invested
- 1h to set up the repo
- 2h to write the whole thing in C
- 2h to write window and display functions
- 2h to write ball-wall interactions + some debugging of earlier issues
- 0.5h to write paddle ai
- 0.5h to write player-ball interaction
- ~2h refinement