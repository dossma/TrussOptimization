# TrussOptimization
Weight optimization of a truss structure via evolution strategy

## Motivation
Truss structures have a weight for which its weight optimal design is not intuitively to determine. This optimization procedure can find the optimal design for minimal weight.  

## Procedure and result

First, the magnitude of the applied force is being set, which is 100 N by default (line 8).
Then, the node coordinates of the truss is being set (lines 11-13). By default, the nodes are such which manifest an equilateral triangle.
All nodes must be included in the node matrix (´Knotenmatrix´) in line 16.
Each rod is connected to two nodes; this configuration is defined in lines 18-21.
After, the configuration of the bearings are set (lines 26-29). The default is a fixed bearing at the bottom left node and a floating bearing at the bottom right node. 

<img src="https://github.com/dossma/scrape-CAMX/blob/main/camx_snapshot.jpg" width=100% height=100%>

<img src="https://github.com/dossma/scrape-CAMX/blob/main/camx_snapshot.jpg" width=100% height=100%>
<img src="https://github.com/dossma/scrape-CAMX/blob/main/Gmaps%20screenshot%20w%20profile.jpg" width=100% height=100%>

## Get started
After the development setup has been established (see below), just run it.

## Development setup
Prominent required external libraries are
- Selenium: https://github.com/SeleniumHQ/selenium
- Geckodriver https://github.com/mozilla/geckodriver

__Selenium:__
```sh
pip install selenium
```
__Geckodriver:__
Download latest release and put it into your development folder, (i.e. C:/Users/yourUsername/Anaconda3). 
Make sure this path is set as environmental variable. 

## Meta

Author: Jonas Dossmann

Distributed under the AGPL-3.0 license.

[https://github.com/dossma/](https://github.com/dossma/)
