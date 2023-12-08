---
title: Applied Machine Learning Resources
subject: Modern 4DVar
subtitle: What components can we use to estimate the state?
short_title: ML Resources
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - CNRS
      - MEOM
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: data-assimilation, open-science
abbreviations:
    GP: Gaussian Process
---


 

This is my aggregation of ML resources over the years. If you google machine learning or deep learning you’re likely find a lot of resources. But in the age of ChatGPT and consultants, we as a society have recognized that we need to filter all of this information to get more personalized recommendations based in our needs. This is my attempt to find the best resources based on my own personal experience.

this is targeted at applied machine for geosciences. So I am assuming someone trained in physical sciences with training in the scientific method and at least a mediocre level of programming experience. Fortunately, machine learning is quite general enough to learn alone because there are many toy problems to motivate the algorithms. However, I believe that geoscience problems have many many characteristics that make it hard to apply ML out of the box. So I will include resources that can perhaps bridge the gap between the two.

<details>
<summary>My Criteria</summary>

I have a set criteria which I try to maximize in order to have a relatively balanced a smorgasbord of resources. In other words, I want a range of resources that cater to different learning styles based on things that I personally think are important for applying ML. 

**Breadth vs Depth.**
Some resources cover a wide range of topics while others dive deep into a few subjects.

**Pillars of Applied ML.**
I consider these to be the pillars of applied ML research: 1) science (or any doman-expertise) which motivate the problems and outline the constraints, 2) the actual machine learning which gives the abstraction and expression for solving the problem, 3) the software which gives the platform to actually encoding these ideas concretely and produce the solutions.

**Practicality.**
I consider the objectives of the users which I divide into two camps: 1) theory and 2) practical. Both are important but they are distinct objectives. One could make the argument that theory always helps, motivates or inspires practical solutions or vice versa. However, let’s not kid ourselves: fundamental theory of the problem is probably not going to help me get a working implementation of a prototype solution under significant time constraints. There is a time and a place.

</details>

<details>
<summary>How to Choose</summary>


**Time**
I am a strong believer that the amount of time you have should be a factor in which resources to choose. If you are a student, an industry worker with a time, or you’re passionate about understanding ML then please take advantage of this and really dive deeper into some of the more lengthy resources like books and supplement it with coding. If you are a postdoc, an industry worker without time, or you’re passionate about using ML and you need to quickly on-board yourself with little to no background, then please skip straight to coding and supplement yourself with the more mathematical bits.

**Learning Objectives**
I am a strong believer that your objective should as be a factor in which resources to choose. If you’re interested in an application and only wish to apply ML as a tool, then go for practical resources. If you're interesting in ML modeling or just have a crazy amount of time and curiousity, then dive a bit deeper and you won't regret it.

**Individual Preferences.** I  am a strong believer in that you should know yourself, what you like, and your learning style should be the ultimate factor in which resources to choose. If you’re a person who learns by doing, pick up the python whirlwind tour, dive deep into a ML library and start coding on day 1. If you’re a person who cannot move forward with their life unless they understand every little thing in a methodological sequential manner, then pick up the ML bible and start with the preface until you finish. If you’re somewhere in between, do a bit of both. It’s that simple.

</details>

---
## Courses


**Crash Course: Deep Learning Fundamentals with PyTorch Lightning** - [Lightning.ai](https://lightning.ai/courses/deep-learning-fundamentals/)
> This is a good course to jump right into with a broad overview of 1) what is deep learning, 2) how is it used, and 3) how can you code it with their package. It has "lightning-quick" demos about ML concepts in conjunction with out to express these concepts using their PyTorch and Lightning.ai packages right away.  The creator has their own book (Python for Machine Learning) which is very good so they have a knack for explaining simple things. The package (Lightning.ai) is the golden standard of how we use PyTorch in the machine learning community.


**Practical Deep Learning for Coders** - Fast.ai - [Part I](https://course.fast.ai/) | [Part 2](https://course.fast.ai/Lessons/part2.html)
> This is a course which does zero - to - ML expert in no time at all. Part I is more focused on fundamentals and part 2 is more focused on the diffusion-based generative AI phase. They take the approach of motiving each topic with examples and then explaining the underlying structures of the models with alternative explanations (outside those of the academic community). They have their own PyTorch-based API which tries to minimize the boilerplate code so you focus on what machine learning is doing and not how it is doing it. I really like this course because the person who taught it is came from a totally different background and went against the grain for how we teach machine learning. Yes: It's possible to teach a course motivated by applications and code and then teach the fundamentals explored along the way. Fast.ai is a [huge community](https://forums.fast.ai/) of fastai-ers all over the world. There is also a book you can supplement your learning with ([Deep Learning for Coders with Fastai and PyTorch: AI Applications Without a PhD](https://www.amazon.com/Deep-Learning-Coders-fastai-PyTorch/dp/1492045527)).


**University Courses** - *Practical+Code* -  [UvA](https://github.com/phlippe/uvadlc_notebooks) | [Sorbonne-Tokyo](https://github.com/acids-ircam/creative_ml)
> These are some more classical resources that teach machine learning as a course at university. I think they do a very good job at covering a wide range of topics with a decent amount of mathematical explanations. They also use state of the art software tools. The resources at UvA come with videos but unfortunately the Sorbonne-Tokyo ones do not. But both have notebooks that are detailed as one can get read it almost as if it were a text book.

**University Courses** - *Lectures+Theoretical* - [Probabilistic Machine Learning](https://www.youtube.com/playlist?list=PL05umP7R6ij1tHaOFY96m5uX3J21a6yNd) | [Numerics of Machine Learning](https://www.probabilistic-numerics.org/teaching/2022_Numerics_of_Machine_Learning/)
> I really enjoyed these lectures from the University of Tübingen. They cover most of the topics you'll see related to probablistic machine learning in the baseline literature. **Note**: This is **probabilistic** ML, not **generative** so they don't talk about anything related to Flows, VAEs, GANs, or diffusion models.


**Dive into Deep Learning** - [Online Book](https://d2l.ai/index.html)
> This is an online textbook of machine learning which takes a very textbook approach to teaching. It is very detailed with code examples for every machine learning concept. They don't really focus on any applications; it's almost a pure ML algorithms textbooks. I don't think this is interesting to read end-to-end but I use it as a reference when I need a bit of detail about how things work along with code examples.




**Machine Learning Summer Schools** - [2023](https://www.youtube.com/@mlss2023/videos) | [2020](https://www.youtube.com/playlist?list=PL1VPPGqQYEUrDAxH9-onsCoLH5f6QuQze) | [2019](https://www.youtube.com/@mlssafrica2758/videos)
> This is a summer school that happens every year. It goes over a wide range of topics related to machine learning from leading experts in the research field. I was priviledged enough to attend during the final years of my PhD. An unforgettable experience that really gave me some perspective on machine learning.


---
### Geoscience Related


**MOOC Weather & Climate** - ECMWF Sponsored (Community Contributed) - [webpage](https://lms.ecmwf.int/course/index.php?categoryid=1)
> Those that are into weather and climate can take a look at this course. It is a massive course with a lot of in-depth material. It's as SOTA as you can get because the ECMWF are [actively working with ML](https://www.ecmwf.int/en/about/media-centre/news/2023/how-ai-models-are-transforming-weather-forecasting-showcase-data) in their weather forecasts so you wont find any better experts than this. In addition, you should checkout the lectures from the annual ECMWF [workshops related to ML](https://events.ecmwf.int/event/304/timetable/).


**Gaussian Process Summer School** (GPSS) - [Webpage](https://gpss.cc)
> I am a big fan of Gaussian processes so I always want to highlight this excellent summer school. I think GPs are extremely useful for a LOT of spatiotemporal problems. They may not be the final solution, but you never know when you need a spatially coherent interpolator as a pre/post-processing step for maps.



---
## **Geoscience Oriented** Material

> I think this section is helpful for both ML researchers to become accustomed to geoscience task and also geo scientists to put their field into the context of ML.


**Modeling and Simulations in Python** - Allen B Downey - [Free Online Book & Code](https://allendowney.github.io/ModSimPy/index.html) 
> This is a really good step-by-step guide to thinking about modeling and simulations. It starts very simple and slowly increases the difficulty of the problems and creativity of the solutions. I loved it because it gave me a framework for thinking about how to design experiments when dealing with simulations. Not all geoscience problems are directly dependent on weather climate simulations so I think it's also worth it to go through this if you're in that camp.


**An Introduction to Earth and Environmental Data Science** - Ryan Abernathy - [Online Jupyter Book](https://earth-env-data-science.github.io/intro.html)
> When working with geoscience, it's most likely that you'll be playing around with data more than working with ML models. They don't tell you this in the job description but everyone knows this. So the better you are at handling, analyzing and visualizaing the data, the better you will be.


**Causal Inference from the True and the Brave** -  [Online JupyterBook](https://matheusfacure.github.io/python-causality-handbook/landing-page.html)
> Causality (and Modeling) is at the forefront of really understanding. Science assumptions embed causality implicitly. However, data-driven techniques for modeling do not have this implicit assumption and we must embed it ourselves or test for it. This book goes through the field of causality which I draw many parallels to when thinking about experimental design. It's a tough read because there is a lot of different terminology. But I think even a light read through the high-level explanations is more than enough to get you thinking with this mindset.



---
## Machine Learning Books



### Geoscience

**Geographic Data Science with Python** - [Online Book](https://geographicdata.science/book/intro.html)

> This is a great book when dealing with spatial data. Many machine learning books don't really tackle spatial data nicely which can cause many problems later. This book nicely outlines spatial data and how we can build simple (yet powerful) models just by thinking about the spatial correlations.

**Data-Driven Science and Engineering** - Brunton & Kutz - [Book](https://www.databookuw.com)
> This is a favourite of mine as it was my first book/course for learning about ML. This book is great because it showcases many ML methods that are motivated by the standard mathematical tools we see in the sciences. In addition, they demonstrate its applicability on a wide range of topics. 
> Both authors are great educators with very good youtube channels ([Brunton](https://www.youtube.com/@Eigensteve) & [Kutz](https://www.youtube.com/@NathanKutzAMATH)) covering a wide range of topics in mathematics for the physical sciences. They run an institute with a lot of interesting ML [talks](https://www.databookuw.com/seminars/)  for applied sciences. They also have a [really great set of lectures](https://www.databookuw.com/page-5/) in how ML is applied in fluid mechanics. This is my go to resource and I am always keeping an eye out for new stuff here.

**Geoscience Books** - [**Geocomputation with R**](https://r.geocompx.org/) 
> This is an online book which focuses on some of the more intricate aspects of geoscience including data and preprocessing. I think all new ML people should have a quick look just to familiarize themselves with concepts from the geostatistics community. They have a lot of similar algorithms but sometimes just different names.


**Geospatial Health Data** - [Using R for Bayesian Spatial and Spatio-Temporal Health Modeling](https://www.routledge.com/Using-R-for-Bayesian-Spatial-and-Spatio-Temporal-Health-Modeling/Lawson/p/book/9780367760670) | [Geospatial Health Data](https://www.paulamoraga.com/book-geospatial-info/)
> I have found that there is quite a large community of geostatistics applied to health data. The data they use always has problems that need to be overcome and the application directly affects the lives of billions of people. I always find inspiration within this community when thinking about data issues. I think geoscience could learn a lot from this community as well.


---
#### Code-First

<details>
<summary>What is Code First?</summary>


These are books that teach machine learning from a programming perspective and supplement it with math. These books will cover more things that you will see in the real world when you actually have to solve problems and get things working. Most of the methods shown in these books are battle-tested methods that have many, many demonstrated use cases in real life and industry. You’ll improve your expression of problems (and some math) into actual code abstractions that piece together to solve the problem. I think a applied ML Researcher and applied ML engineers will benefit from this breadth of knowledge.

</details>




**Approaching (Almost) Any Machine Learning Problem** - Abhishek Thakur - [Amazon](https://www.amazon.com/Approaching-Almost-Machine-Learning-Problem/dp/8269211508) 
> An excellent book that lives up to its name: it really does cover 95% of the problems you see ML applied in the real world. A very good quickstart which comes from real-world experience. The author is one of the [top kagglers in the world](https://www.kaggle.com/abhishek), has a [youtube channel](https://www.youtube.com/AbhishekThakurAbhi), and is currently working at HuggingFace. As applied as you can get.


**Data Science from scratch** - Joel Grus - [Amazon](https://www.amazon.com/Data-Science-Scratch-Principles-Python/dp/1492041130)
> This book does some of the core data science / machine learning algorithms from scratch. And when he says from scratch, he means from scratch. You code in pure python and you don't use any packages whatsoever. You also slowly build your own tools which you reuse through each of the chapters. I really like the style of storytelling to explain the problem and walkthrough the solutions. I really enjoyed this book. The [author](https://joelgrus.com) is an interesting character who does a few [very interesting](https://www.youtube.com/watch?v=MW9oVxjJHEw&pp=ygUJam9lbCBncnVz) ([opinionated](https://www.youtube.com/watch?v=3Fa6uzHxTkQ&pp=ygUJam9lbCBncnVz)) talks and has a [youtube channel](https://www.youtube.com/@JoelGrus).


**Deep Learning with Python** - François Chollet - [Amazon](https://www.amazon.com/Deep-Learning-Python-Francois-Chollet/dp/1617294438)
> This book comes from the creator of [keras](https://keras.io) (and [keras-core](https://keras.io/keras_core/announcement/)) himself! He is a pioneer in creating the pivotal software that allow ML researchers to express themselves. It also saved tensorflow and made it useful for the masses again. It's a really good book that introduces deep learning from a more hollistic perspective. He still has some rigor but I think he gives more interesting, thoughtful opiniones. Obviously he uses keras throughout the entire book but it really demonstrates how to keras to express yourself in a clean way for most deep learning problems.


**Hands on Machine Learning with scikit-learn and tensorflow** - Aurélien Géron - [Book](https://www.oreilly.com/library/view/hands-on-machine-learning/9781492032632/) | [Code](https://github.com/ageron/handson-ml2)
> This is a solid book. It is an end-to-end introduction of all of machine learning you get in a course but using code. He has a similar style as François Chollet so I found this quite nice to read through.

---
#### Math-First

<details>
<summary>What is Math First?</summary>

These are books that teach machine learning from a mathematical perspective and supplement it with code. These books will categorize and cover each class of ML algorithm and give the reader deeper, mathematical understanding of what’s going on under the hood. These books will cover more things that you see in the research world that may or may not be in the real world. This sort of thing is really good when there are new problems with a special something (e.g., constraints, objective) that you just can’t quite fit into a standard problem.  I also suspect that there are many nuggets of wisdom embedded here that are industry secrets that the research world isn’t privy to - it’s what pays the big bucks in applied ML Research. I think ML researchers will benefit from this deep-dive into the mathematical concepts that drive ML.

</details>



**The 100 Page ML book** - Andriy Burkov - [Book](https://themlbook.com)
> It's true. In only 100 pages, he hits upon almost all of the ML concepts with good and consistent mathematical notation. I was impressed. This is obviously a great crash course for anyone (even PIs).


**Probabilistic Machine Learning** - Kevin Murphy -  [Book 1](https://probml.github.io/pml-book/book1.html) [Code](https://github.com/probml/pyprobml/tree/master/notebooks/book1) | [Book 2](https://probml.github.io/pml-book/book2.html) ([Code](https://github.com/probml/pyprobml/tree/master/notebooks/book2)) 
> This is the unofficial handbook of ML. You can find almost every single topic you can find in the machine learning literature. It is also mathematically rigorous and you can see the derivations or it links to where you can find derivations (when applicable). It's absolutely amazing how much knowledge is condensed within this book. Now, it is a handbook so do not read this cover to cover. However, I always come back to this book whenever I need something. Part 1 covers the basics that everyone should understand like foundations of probability, linear models, nonparametric models and basic unsupervised learning.  Part 2 covers the more advanced topics more related to deep learning, approximate inference, and reinforcement learning. This is a must have on everyones desk. There is also some code to accompany the book as many of the figures can be reproduced with code examples.


**Introduction to Statistical Learning** - James et al. - [Book](https://www.statlearning.com)
> This is also a favourite of mine as it is the book I read during my masters (in 2015) when I started working with machine learning. This might be one of the oldest books within this list but it's packed with knowledge that stand the test of time. There is no deep learning at all but it covers the other standard ML topics with a good amount of rigour and excellent toy examples to gain understanding. They also have a [free online course](https://www.statlearning.com/online-course) that helps supplement the book (I took an older course back in 2015 and I enjoyed it).
> **Note**: It also might be worth keeping this word ("statistical learning") in your vocabulary when dealing with skeptics who aren't convinced with machine learning or deep learning.



**Machine Learning for Engineers** - Osvaldo Simeone - [Book](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwixjvHcoaSBAxVLVaQEHUXaB0wQFnoECBIQAQ&url=https%3A%2F%2Fwww.cambridge.org%2Fhighereducation%2Fbooks%2Fmachine-learning-for-engineers%2F7FD8622836CAFCF5EDB169E7DC8A1ED4&usg=AOvVaw3Jru-7fum3cHCwJn63U37T&opi=89978449)
> This is my most recently read book in my. I find it has a very, well-done, methodological introduction to ML. It is a bit more big picture of the algorithms and how they are all related to Bayesian principles. This one surprised me but I find that I personally think very similar to how the work was presented so this has become a new favourite of mine.


**Probabilistic Numerics: Computation as Machine Learning** - Hennig et al. - [Book]( https://www.probabilistic-numerics.org/textbooks/) | [Website](https://www.probabilistic-numerics.org) | [Code](https://www.probabilistic-numerics.org/code/)
> This is a new an emerging field of machine learning where they are interested in using machine learning in the actual numerical algorithms that we use daily. For example, linear algebra, integration, ODEs, optimization, etc. They kind of revist the computations we take for granted and think about how we can improve those methods which will improve everything; including our simpler algorithms. They have a lot of interesting research and I personally believe that this will make a bit impact in how we program. The scientific machine learning community should pay close attention to their work. They have a great course - [Numerics of Machine Learning](https://www.youtube.com/playlist?list=PL05umP7R6ij2lwDdj7IkuHoP9vHlEcH0s) which goes into even more detail about some of the SOTA research in this area. Their other [probabilistic machine learning course](https://www.youtube.com/playlist?list=PL05umP7R6ij2YE8rRJSb-olDNbntAQ_Bx) was also excellent.



---
## Machine Learning Operations (MLOps)

> In research, we mostly work on problems that demonstrate ML usefulness in a geoscience task. But once we have you the model, how can one use it and maintain its performance. I think it’s important to get an overview of the ML model lifecycle from idea inception, to model prototype, to deployment. Even if you never do deployment, I think it’s good to have an understanding of that portion of the ML life cycle. 


**Made with ML** - [Online Tutorials](https://madewithml.com)
> This gives a great overview of the MLOps world from start to finish. Everything is organized very well so we can take each piece individually. This is a great reference for me when I am thinking about the full ML life cycle.


**Continuous Machine Learning** - DTU - [Webpage with Code](https://skaftenicki.github.io/dtu_mlops/)
> This is an excellent course from DTU which takes you step by step through the process of building an ML model and putting it in deployment. I also really enjoyed this course.


---
