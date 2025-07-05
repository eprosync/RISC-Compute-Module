# Simple Compute Module
An experiment with writing a turing complete computer with RISC (not V...).\
This implements my own discoveries and achievements that I've learned thus far.\
Used as the basis for other things I may use this for.

## Datapath
The datapath can be best shown through this image below.\
This is just a simple top-level view of how it should all work under `datapath.v`.
![Datapath Example](/datapath.png)

## Instruction Set Architecture (ISA)
**Common**\
Rsrc1 [31-27] | Rsrc2 [26-22] | Rdst [21-17] | OP [16-0]

**Immediate**\
Rsrc1 [31-27] | Rsrc2 [26-22] | Imm [21-6] | OP [5-0]

**Call**\
Imm [31-6] | OP [5-0]