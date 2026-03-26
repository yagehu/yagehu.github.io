#import "@preview/slipstshow:0.1.0": *

#set quote(block: true)

#show: slipstshow.with()

= Classifying Memory Access Patterns for Prefetching

ASPLOS \'20

#image(width: 70%, "authors.png")

#pause()

== Background: Prefetching <prefetch>

#pause(up: <prefetch>)

- *Memory Wall*
  - Growing speed disparity between fast _processor_ and slow _main memory_

#quote[
  ... cycle time of modern processors is now two orders of magnitude
  smaller than the access latency of DRAM.
]

-
