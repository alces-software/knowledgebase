.. _verification-considerations:

Considerations for HPC Platform Verification
============================================

Before putting the system into a production environment it is worth verifying that the hardware and software is functioning as expected. The 2 key types of verification are:

  - **Configuration** - Verifying that the system is functioning properly as per the server setup.
  - **Performance** - Verifying that the performance of the system is as expected for the hardware, network and applications.

Verifying the configuration
---------------------------

Simple configuration tests for the previous stages of the HPC platform creation will need to be performed to verify that it will perform to user expectations. For example, the following could be tested:

  - Passwordless SSH between nodes performs as expected
  - Running applications on different nodes within the network
  - Pinging and logging into systems on separate networks

Best practice would be to test the configuration whilst it is being setup at regular intervals to confirm functionality is still as expected. In combination with written documentation, a well practiced preventative maintenance schedule is essential to ensuring a high-quality, long-term stable platform for your users. 

Testing System
--------------

There are multiple parts of the hardware configuration that can be tested on the systems. The main few areas are CPU, memory and interconnect (but may also include GPUs, disk drives and any other hardware that will be heavily utilised). Many applications are available for testing, including:

  - Memtester
  - HPL/Linpack/HPC-Challenge (HPCC)
  - IOZone
  - IMB
  - GPUBurn

Additionally, benchmarking can be performed using whichever applications the HPC platform is being designed to run to give more representable results for the use case.

Additional Considerations and Questions
---------------------------------------

- How will you know that a compute node is performing at the expected level?

  - Gflops theoretical vs actual performance efficiency
  - Network performance (bandwidth, latency, ping interval) 
  
- How can you test nodes regularly to ensure that performance has not changed / degraded?

