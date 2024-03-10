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