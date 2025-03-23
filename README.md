# RISC-V Microarchitecture
## Learning how to develop RISC-V core microarchitecture
I will be following along to the material discussed in the book Digital Design and Computer Architecture by Harris and Harris. They also have a very nice Youtube video series here [https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=video&cd=&cad=rja&uact=8&ved=2ahUKEwjmjOjI9J6MAxW_hlYBHeRJO3kQtwJ6BAgIEAI&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DlrN-uBKooRY&usg=AOvVaw2KkbnKYw8rpSGptifGRntO&opi=89978449]

I will try to implement the same examples using TL-Verilog by Redwood EDA [https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwi79fqK9Z6MAxWrr1YBHXhBIwYQFnoECDYQAQ&url=https%3A%2F%2Fwww.redwoodeda.com%2F&usg=AOvVaw3Pm5SkIWosBsHEa_xFm9jF&opi=89978449]. I will be using the Makerchip IDE, installed locally on Windows Subsystem Linux (WSL) Ubuntu.

### Dev Environment Setup
1. Install and start WSL.
2. In the WSL shell install google chrome.
3. In the WSL shell prepare and activate a python environment.
4. In the activated environment, install and run makerchip app [https://gitlab.com/rweda/makerchip-app].

I will study all three microarchitectures:
1. Single cycle
2. Multi cylcle
3. Pipeline

# RISC-V Microarchitecture
## Learning how to develop RISC-V core microarchitecture
I will be following along to the material discussed in the book Digital Design and Computer Architecture by Harris and Harris. They also have a very nice Youtube video series [here](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=video&cd=&cad=rja&uact=8&ved=2ahUKEwjmjOjI9J6MAxW_hlYBHeRJO3kQtwJ6BAgIEAI&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DlrN-uBKooRY&usg=AOvVaw2KkbnKYw8rpSGptifGRntO&opi=89978449).

I will study all three microarchitectures:
1. Single cycle
2. Multi cylcle
3. Pipeline


I will try to implement the same examples using [TL-Verilog by Redwood EDA](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwi79fqK9Z6MAxWrr1YBHXhBIwYQFnoECDYQAQ&url=https%3A%2F%2Fwww.redwoodeda.com%2F&usg=AOvVaw3Pm5SkIWosBsHEa_xFm9jF&opi=89978449). I will be using the Makerchip IDE, installed locally on Windows Subsystem Linux (WSL) Ubuntu.

### Dev Environment Setup
#### Install and start WSL
The detailed instructions are [here](https://learn.microsoft.com/en-us/windows/wsl/install). Basically in a Windows Command Prompt
```
>wsl --install
```
This installs the default Ubuntu distro for the susbsystem.

#### Install Google Chrome
Start the WSL and install Google Chrome, delails [here](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps). The Makerchip IDE is browser based and Chrome is recommended.
```
$cd /tmp

$wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

$sudo apt install --fix-missing ./google-chrome-stable_current_amd64.deb
```

#### Setup a Python environment
In the WSL shell prepare and activate a python environment.
```
$python3 -m venv .venv
```
And activate it
```
$source .venv\bin\activate
```
#### Install Makerchip App
In the activated environment, install and run makerchip app. The details are found [here](https://gitlab.com/rweda/makerchip-app), but basically
```
(.venv)$pip3 install makerchip-app
```
To start a project run
```
(.venv)$makerchip design.tlv
```




