# scrumble

A static site generator for plain ol' HTML and CSS.

It's called scrumble because scrumble is what it does. Markdown goes in,
website comes out.

## Usage

1. Set up your directory structure. You need a `posts` directory and a `pages`
directory for markdown content, a `media` directory for images (with
`favicon.png` inside), and your template files: `header.html`, `footer.html`,
and `style.css`. Scrumble won't scrumble if you're missing any of these.
2. `scrumble.tcl <site title>` to scrumble the markdown and HTML fragments into
something resembling a website.

`header.html` must contain an empty `<nav>` tag pair. Both posts and pages
require a Pandoc-style title block, although the date is not used for pages and
may be omitted:

    % Title
    % Author
    % Date

## Dependencies

* Tcl
* Pandoc
