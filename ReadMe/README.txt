Basic Computer Organization Project using Protous and Verilog

Introduction:

This project aims to design and implement a basic computer system using Verilog, and simulate an electronic circuit using Proteus.
The system performs basic operations like Fetch-Execute Cycle, arithmetic and logical operations,
 and memory management using a central processing unit (CPU).

Design:

The project involves the design of a simple computer with the following components:

Memory: 256 words x 16 bits.

Registers:

IR (Instruction Register)

TR (Temporary Register)

DR (Data Register)

AC (Accumulator)

PC (Program Counter)

AR (Address Register)

timeCount (Time Counter)


Key Components:

I: Indirect bit

E: Extend (carry) flip-flop

S: Start/Stop flip-flop



Architecture:

The core of the project is the BasicComputer module, which contains a CPU that stores operations in memory and executes them according to the stored instructions. The code includes:

Memory Initialization: The memory is initialized with instructions, and initial values are assigned to all registers.

Fetch-Execute Cycle: The instructions are fetched from memory, and then executed based on the values stored in the registers.


Code Overview:

BasicComputer Module:

The code includes a central processor that executes instructions such as:

Register-Reference Instructions: (CLA, CLE, INC, etc.)

Memory-Reference Instructions: (AND, ADD, LDA, STA, etc.)

Support for Indirect or Direct addressing modes.


Code Components:

Memory Allocation: The memory is allocated with 256 locations (16-bit each).

Timing Logic: The operations are simulated with a timing mechanism (timeCount) to execute operations sequentially.


Testbench:

A Testbench is included to simulate and test the functionalities of the computer:

Clock pulses are generated to drive the system.

The values of the registers (IR, TR, DR, AC, PC, AR) are displayed at each clock cycle.

Data is exported to a VCD file for viewing waveforms.


Features:

1. Fetch-Execute Cycle Simulation: The traditional fetch-execute cycle of a computer is simulated in a Verilog environment.


2. Memory and Data Handling: The system simulates loading and storing data in memory and registers.


3. Instruction Handling: Several types of instructions like AND, ADD, LDA, STA are supported.


4. Proteus Simulation: A Proteus schematic is created to visualize and simulate the behavior of the computer.



How to Use:

1. Simulation Setup:

Open the Testbench file in a Verilog simulator.

Run the simulation using a simulator like ModelSim or any Verilog-compatible simulator.



2. Waveform Visualization:

If the VCD file is exported, open it using tools like GTKWave to observe the waveform and behavior of the processor.



3. Running the Simulation:

You can also use the Proteus file to run the simulation visually.




Documentation:

Instructions Used in the Project:
The following instructions are implemented in the code:

CLA (Clear Accumulator): Clears the accumulator register.

CLE (Clear Extend): Clears the Extend flip-flop.

CMA (Complement Accumulator): Complements the accumulator register.

CME (Complement Extend): Complements the Extend flip-flop.

INC (Increment): Increments the accumulator register.

SPA (Skip if Positive Accumulator): Skips the instruction if the accumulator is positive.

STA (Store Accumulator): Stores the accumulator's value in memory.



Challenges and Notes:

Memory Management: Synchronizing memory and registers is critical for proper functioning.

Indirect Addressing: Proper handling of indirect operations was implemented to avoid complexity.


Conclusion:

This project demonstrates the design of a simple computer at the circuit level using Verilog and simulates the processor's behavior.
 It helps understand key concepts like the fetch-execute cycle, internal CPU organization, and memory operations.