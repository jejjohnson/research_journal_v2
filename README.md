# Research Notebook

* Author: J. Emmanuel Johnson
* Email: [jemanjohnson34@gmail.com](mailto:jemanjohnson34@gmail.com)
* Twitter: [jejjohnson](https://twitter.com/jejjohnson)
* Github: [jejjohnson](https://github.com/jejjohnson)
* Website: [jejjohnson.netlify.app](https://jejjohnson.netlify.app)
* Website: [jejjohnson.github.io/research_notebook](https://jejjohnson.github.io/research_notebook)
* Github Repo: [https://github.com/jejjohnson/research_notebook](https://github.com/jejjohnson/research_notebook)

---

I recently ran into someone at a conference who said, "*a lot of research dies in Graduate students laptops*" (it was actually this [scientist right here](https://twitter.com/jennifermarsman)). So I decided to go through all of my stuff, organize it a little bit and make it public.

This is my research journal  of various topics that I'm working with. My research is mostly in using Machine learning methods in various applications of remote sensing, ocean and climate sciences. I focus on three factors:

* **Data Representation** - We know that spatial-temporal information is important; can we effectively capture this in ML models?
* **Modeling Uncertainty** - Which ML models allow us to capture any facets of uncertainty (input, model, output) in our  models.
* **Similarity Measures** - What is similarity and how are we able to measure it using ML?
  
These are very difficult questions but I think they are very helpful for the community in general. The predominant algorithms of interest include kernel methods like Gaussian Processes (GPs) and Invertible Flows like Gaussianization Flows (GFs) for density and dependence estimation.

---

Some other things you'll find are:

* Python and good coding practices
* Remote Computing and efficiency hacks
* I hoard a lot of links...
* Deep Learning in practice
* Eventually some blog posts...

---

<!-- ### [Project Webpages](projects/README.md) -->

### Notes

> My notes that I have been accumulating over the years. These will eventually go into my thesis, current/future publications and hopefully I'll master it enough to teach to someone one day.

### Lab Notebook

> I like to tinker around with different bits of code. I try a lot of things that may or may not be useful. But the journey sometimes is worth sharing for sure.

### Resources

> My resources for all things python and tech. I like to tinker with different packages so I try to document my findings.

### Tutorials

> I do like to give back to the community. So I have compiled some tutorials that will hopefully be helpful to other people.

### Snippets

> I write lots of bits of code everywhere and it tends to be disorganized. I'm trying to organize my bits of code everywhere into digestable snippets; kind of like a personal reference.


These are my notes for my research journey.

---

## Usage

### Building the book

If you'd like to develop on and build the research_notebook book, you should:

- Clone this repository and run
- Run `pip install -r requirements.txt` (it is recommended you do this within a virtual environment)
- (Recommended) Remove the existing `research_notebook/_build/` directory
- Run `jupyter-book build research_notebook/`

A fully-rendered HTML version of the book will be built in `research_notebook/_build/html/`.

### Hosting the book

The html version of the book is hosted on the `gh-pages` branch of this repo. A GitHub actions workflow has been created that automatically builds and pushes the book to this branch on a push or pull request to main.

If you wish to disable this automation, you may remove the GitHub actions workflow and build the book manually by:

- Navigating to your local build; and running,
- `ghp-import -n -p -f research_notebook/_build/html`

This will automatically push your build to the `gh-pages` branch. More information on this hosting process can be found [here](https://jupyterbook.org/publish/gh-pages.html#manually-host-your-book-with-github-pages).

## Contributors

We welcome and recognize all contributions. You can see a list of current contributors in the [contributors tab](https://github.com/jejjohnson/research_notebook/graphs/contributors).

## Credits

This project is created using the excellent open source [Jupyter Book project](https://jupyterbook.org/) and the [executablebooks/cookiecutter-jupyter-book template](https://github.com/executablebooks/cookiecutter-jupyter-book).
