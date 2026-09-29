#import "@preview/modernpro-coverletter:1.0.2": *

// Edit identity and contacts here. Keeping them beside the letter content
// makes this starter a self-contained document with no personal-data imports.
#let profile = (
  name: [Jonathan Camp],
  role: [Infrastructure Engineer/Software Developer],
  address: [Philadelphia, USA],
  contacts: (
    (text: [jon\@skyreach.llc], link: "mailto:jon@skyreach.llc"),
    (text: [cv.joncamp.cloud], link: "https://cv.joncamp.cloud"),
    (text: [he/him]),
  ),
)

// Job-application cover letter. Everything below `profile` and `recipient` is optional:
//   preset: "compact" | "default" | "relaxed"   vertical rhythm
//   accent: rgb("#1e3a5f")                      the one colour in the document
#show: coverletter.with(
  profile: profile,
  recipient: (
    name: [Mei Walker],
    role: [Hiring Manager],
    department: [Software Engineering],
    organization: [Fenris Creations],
    date: [28 September 2026],
    subject: [Application for Senior Infrastructure Engineer],
    greeting: [Dear Mei Walker,],
  ),
)

Having just departed for home from my third visit to Iceland, I'm writing this on the plane in hopes of finding a path back, more permanent this time. I'm applying for your Senior Infrastructure Engineer position.

My years in ad tech line up with several of the problems in your posting: keeping state consistent when part of the system goes down, limiting the blast radius of failures, and serving responses within milliseconds. To pull a few examples from my five years at Revcontent where the overlap is clearest: I partitioned event streams so aggregate state stayed bounded and ordered, rerouted live traffic away from degraded regions, and moved our pipeline from Kinesis to Kafka to own our recovery. Partitioning simulation load across nodes looks like a similar shape of problem, although you can't just catch up or replay an event stream in a real-time simulation like we could in my prior problem spaces. I find these types of problems intriguing, especially diving into what makes them unique and can't be solved with an off-the-shelf solution.

This opportunity is especially exciting because I'd finally be able to contribute to gaming, a lifelong love of mine. The engineering puzzles you are faced with and solutions like time dilation seem genuinely interesting.

On the practical side: coming from the United States, I would need sponsorship through the expert-knowledge permit route. I'm ready to relocate and looking forward to living in Iceland.

I'd welcome the chance to talk through how this experience maps onto balancing the simulation workload across nodes, as well as exploring the differences. Thank you for your consideration.
