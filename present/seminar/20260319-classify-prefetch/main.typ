#import "@preview/showybox:2.0.4": showybox
#import "@preview/slipstshow:0.1.0": *

#set quote(block: true)

#show: slipstshow.with(base-font-size: 32pt)

= Classifying Memory Access Patterns for Prefetching

=== ASPLOS \'20

#image(width: 70%, "authors.png")

#pause()

== Background: Prefetching <prefetch>

#pause(up: <prefetch>)

- *Memory Wall*
  - Growing speed disparity between fast _processor_ and slow _main memory_.

#quote[
  ... cycle time of modern processors is now two orders of magnitude
  smaller than the access latency of DRAM.
]

#pause()

- Speculatively moves data from slow memory into fast caches in advance.
  - Good guess #sym.arrow elimiates a miss
  - Bad guess #sym.arrow pollutes the cache

#pause()

== State-of-the-Art Prefetchers ...

#pause()

#slips(
  subslip[
    === ... in Academia <sota-academia>

    - Stream prefetchers
    - Correlation prefetchers
    - Execution-based prefetchers
      - Idea: Runahead execution with another hardware thread.

    #pause(up: <sota-academia>)
  ],
  subslip[
    === ... in Industry <sota-industry>

    - Only simple, conservative designs even in modern chips like Intel Xeon

    #pause()

    - Next-line prefetcher
      - Idea: If the CPU access cache line $n$, prefetch line $n + 1$.
      - Relies on spatial locality, extremely cheap to implement.

    #pause()

    - Stride prefetcher
      - Idea: Detect constant $delta$ between consecutive accesses to the
        same memory page of from the the PC. If a PC shows a pattern of
        accessing $n$, then $n + delta$, then prefetch $n + 2 delta$.
      - Handles simple strides like:
        ```c
        for (int i = 0; i < 1000; i += 2)
        ```

    #pause(up: <sota-industry>)
  ],
)
#step

== Motivation <motivation>

- *Problem*: Limited understanding of memory access behaviors.
  - Various prefetchers that work for specific applications
  - Unclear whether a new application will benefit from some prefetcher design

#pause(up: <motivation>)

- *Interesting Questions*
  - What percentage of application cache misses can be handled by a particular prefetcher?
  - What are the upper bounds for application miss coverage and performance
    improvement that a given prefetcher can provide.
  - What type of prefetcher capabilities are required to prefetch
    a certain memory access pattern?
  - How much opportunity is there for a prefetcher to run ahead and
    emit timely prefetches for a given cache miss?

#pause()

#html.frame(
  block(
    width: 16cm,
    showybox(
      title: "Contributions",
      [
        Develop a novel dataflow-based methodology to understand and
        classify all of the memory access patterns of applications.
      ],
      [
        Implement a tool that extracts "prefetch kernels," which are graphs
        representing the computation for a memory address, and automatically
        determines the complexity of the access pattern.
      ],
      [
        Propose a new software prefetcher design based on dataflow analysis
        that greatly outperforms the stride-based baseline with minimal
        hardware cost.
      ],
    ),
  )
) <contrib>

#pause(up: <contrib>)

#slips(
  subslip[
    === Memory Access Classification <mem-classify>

    #image(width: 100%, "mem-classification.png")

    #pause(up: <mem-classify>)

    *Insights*:

    - Can determine the capabilities required by a prefetcher
      to address a certain percentage of misses.
    - Can quantify the efficacy of prefetchers that support certain patterns.
    - Better understanding of prefetcher timeliness:
      - e.g. for delta pattern: $A_n = A_(n - k) + d times k$
      - e.g. for pointer chase, running ahead is difficult

    #pause()

    ==== Formalization

    - Classification is useful for human analysis
      but hard for automated reasoning.
    - Complex applications will use compositions or variations.

    #pause()

    #quote[
      For a given load instruction and its function to compute the next address,
      $f(x)$ can be expressed as a _prefetch kernel_ which consists of a
      number of _data sources_ and _operations_ on those sources which generate
      the delinquent load address.
    ]

    #pause()
  ],
  subslip[
    === Prefetch Kernel Extraction <kernel-ext>

    - Each miss is caused by an address calculated by one or more instructions
    - *Goal*: Extract and classify address-generating instructions for each miss
    - *Challenge*
      - Intractable number of dataflow paths in most programs

    #pause(up: <kernel-ext>)

    #html.frame(
      block(
        width: 16cm,
        showybox(
          title: "Approach",
          [Collect application traces with DynamoRIO (Memtrace).],
          [
            - Collect cache miss profile
              - Ranked list of PCs that cause cache misses
              - Application- and architecture-specific
          ],
          [
            - Build dataflow graphs for each miss-causing instruction
              - Data dependency graph #sym.arrow.l.r Prefetch kernel
                - Fully describes the data and computations required to form a
                  miss address.
                - Vertices represent operands (constants, registers, or memory locations).
                - Edges encode the operations between vertices that form the data dependencies.
                - Root vertex is the miss-causing instruction address
          ],
        ),
      )
    )

    #pause()

    ```c
    void simple_chase(Node * node, int count) {
      for (int i = 0; i < count; i++) {
        do_work(node);
        node = node->next;
      }
    }

    void do_work(Node * node) {
      node->field[6] = node->field[5] + node->field[4];
    }
    ```

    #pause()

    #image(width: 30%, "linked-list-kernel.png")

    #pause()

    $
      A_n & = "0x28" + "load"("0x38" + "load"(-"0x8" + "load"(r s p))) \
      A_n & = "0x28" + "load"("0x38" + r a x)
    $

    $ r a x_n = "load"(r a x_(n - 1) + "0x38") $

    Linked list traversal classification pattern:

    $
      A_n & = B_n + c_1 \
      B_n & = L d (B_(n - 1) + c _ 2)
    $

    $$

    #pause()
  ],
  subslip[
    === New Software Prefetcher <prefetcher-impl>

    - Execute the target binary to obtain execution traces and miss profiles
    - Performs dataflow analysis
    - Injects prefetches into a new binary
    - Limitations of prior work
      - Require manual annotation
      - Limited access patterns
      - Limited knowledge of timeliness of a prefetch

    #pause(up: <prefetcher-impl>)
  ],
)
#step

#image(width: 100%, "mem-access-patterns.png")

#pause()

#image(width: 40%, "kernel-ops.png")

#pause()

#image(width: 100%, "speedup.png")

#pause()
