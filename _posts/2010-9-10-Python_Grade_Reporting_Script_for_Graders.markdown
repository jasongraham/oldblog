---
layout: post
title: Python Grade Reporting Script for Graders
tags: [code, school, python]
time: '19:11'
---

One of the classes that I'm TA-ing for this term is an introductory computer science class with 100 students.  They have a weekly programming assignment which takes quite a while to grade.  The professor has asked me to give each student individual feedback through email on their submissions.  Naturally, this could potentially suck up tons of time sending emails all around.

What I had done, and I'm sure many others do, is create a spreadsheet to organize their grades.  But how could I send an email to each student with their grade and my comment quickly?  The students are learning [Python], so I thought, what better way to deal with the problem than in Python?[^1]

*[TA]:Teaching Assistant
[^1]: Not only that, but it's my first time using Python myself, so this is good practice.
[Python]:http://en.wikipedia.org/wiki/Python_(programming_language)

At any rate, I wanted to share [my script].  I'm sure it's amateurish as far as Python goes, or even if it would be useful to anyone; I'm not exactly a master coder in any language, let alone my newest.  It uses [msmtp] to send the mail.  This probably would be the biggest hurdle in making this portable, but I didn't have the patience to code the script to work this way tonight.  I may update it with native Python email capabilities in the future.

[my script]:http://code.the-graham.com/report_grades/tree/report_grades.py
[msmtp]:http://msmtp.sourceforge.net/

