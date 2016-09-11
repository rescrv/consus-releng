# coding=utf8
# Copyright (c) 2013-2014, Robert Escriva
# All rights reserved.

import os
import os.path
import re
import shutil
import subprocess
import sys
import urlparse

from bs4 import BeautifulSoup
from bs4 import UnicodeDammit
import bs4.element as Elements

def soup_in(filename):
    return BeautifulSoup(UnicodeDammit.detwingle(open(filename).read()).decode('utf8'), 'html.parser')

def soup_out(soup, filename):
    f = open(filename, 'w')
    f.write(unicode(soup).encode('utf8'))
    f.flush()
    f.close()

################################################################################
#################################### Filters ###################################
################################################################################

############################## remove bad classes ##############################

BAD_CLASSES = set([
    'indent',
    'noindent',
    ])

def filter_bad_classes(filename):
    soup = soup_in(filename)
    for tag in soup():
        if not tag.has_attr('class'):
            continue
        classes = [x for x in tag['class'] if x not in BAD_CLASSES]
        if not classes:
            del tag['class']
        else:
            tag['class'] = classes
    soup_out(soup, filename)

############################# remove some nav divs #############################

def filter_undesirables(filename):
    soup = soup_in(filename)
    for tag in soup.findAll('div'):
        if tag.has_attr('class') and 'crosslinks' in tag['class']:
            tag.extract()
    for tag in soup():
        if tag.has_attr('class') and 'likechapterToc' in tag['class']:
            tag = tag.extract()
        elif tag.has_attr('class') and 'likechapterHead' in tag['class']:
            tag = tag.extract()
    soup_out(soup, filename)

########################## fixup the Table of Contents #########################

def filter_contentsname(references, path, index):
    filename = os.path.join(path, 'contentsname.html')
    filter_bad_classes(filename)
    filter_undesirables(filename)
    soup = soup_in(filename)
    for a in soup.findAll('a'):
        url = a.get('href')
        if not url:
            continue
        u = urlparse.urlparse(a.get('href'))
        if u.scheme != '' or u.netloc != '':
            continue
        assert u.path.endswith('.html') or u.path == ''
        fragment = u.fragment
        if fragment and fragment not in references:
            print('warning: unknown refid %r in %r' % (fragment, filename))
        fragment = references.get(fragment, fragment)
        if fragment != u.fragment:
            if a.has_attr('id') and a['id'] not in references:
                references[a['id']] = u.fragment
            u = ('', '', u.path, u.params, u.query, fragment)
            a['href'] = urlparse.urlunparse(u)
            a['id'] = fragment
    soup_out(soup, index + '.html')
    os.unlink(filename)

############## Turn TeX4ht references into human-readable strings ##############

def filter_references(references, index, filename):
    soup = soup_in(filename)
    for a in soup.findAll('a'):
        url = a.get('href')
        if not url:
            continue
        u = urlparse.urlparse(url)
        if u.scheme != '' or u.netloc != '':
            continue
        assert u.path.endswith('.html') or u.path == ''
        fragment = u.fragment
        if fragment and fragment not in references:
            if u.path == index + '.html' and u.fragment.startswith('QQ') and a.has_attr('id'):
                fragment = a['id']
            else:
                print('warning: unknown refid %r in %r' % (fragment, filename))
                continue
        if not fragment:
            continue
        while references.get(fragment, fragment) != fragment:
            fragment = references.get(fragment, fragment)
        path = u.path
        if u.path == 'contentsname.html':
            path = index + '.html'
        u = ('', '', path, u.params, u.query, fragment)
        a['href'] = urlparse.urlunparse(u)
    for tag in soup():
        if not tag.has_attr('id'):
            continue
        if tag['id'] in references:
            tag['id'] = references[tag['id']]
    soup_out(soup, filename)

########################## Change div.fancyvrb to pre ##########################

def filter_fancyvrb(filename):
    soup = soup_in(filename)
    for tag in soup.select('.fancyvrb > tspan'):
        assert(len(list(tag.children)) == 1)
        if tag.parent is not None:
            tag.replace_with(list(tag.children)[0])
    for tag in soup.select('.fancyvrb br'):
        if tag.parent is not None:
            tag.replace_with('\n')
    for tag in soup.select('div.fancyvrb'):
        tag.name = 'pre'
    soup_out(soup, filename)

################################ remove comments ###############################

def filter_comments(filename):
    soup = soup_in(filename)
    def is_comment(text):
        return isinstance(text, Elements.Comment)
    comments = soup.findAll(text=is_comment)
    [comment.extract() for comment in comments]
    soup_out(soup, filename)

######################### substitute bad unicode chars #########################

def filter_unicode(filename):
    data = open(filename).read()
    tr = {'’': "'"}
    for k, v in tr.items():
        data.replace(k, v)
    open(filename, 'w').write(data)

######################## wrap it in jinja leaf templates #######################

def filter_jinja(prefix, filename):
    soup = soup_in(filename)
    s = soup.prettify()
    assert '<body>' in s
    assert '</body>' in s
    s = s[s.index('<body>') + 6:]
    s = s[:s.index('</body>')]
    s = s.strip()
    s = '''{% extends "doc.html" %}

{% block content %}
''' + s
    s += '\n{% endblock %}\n'
    f = open(filename, 'w')
    f.write(s.encode('utf8'))
    f.flush()
    f.close()

################################################################################
################################## Processing ##################################
################################################################################

def list_html_files(path):
    files = [os.path.join(path, x) for x in os.listdir(path)
             if x.endswith('.html')]
    for x in files:
        assert os.path.isfile(x)
    return files

def gather_references(path):
    ref_re = re.compile(r'\\newlabel\{(?P<refname>.*?)\}.*?\\rEfLiNK\{(?P<refid>.*?)\}')
    references = {}
    for aux in os.listdir(path):
        if not aux.endswith('.aux'):
            continue
        for line in open(os.path.join(path, aux)):
            if not line.startswith('\\newlabel'):
                continue
            m = ref_re.search(line)
            if m:
                gd = m.groupdict()
                references[gd['refid']] = gd['refname']
    for v in references.values():
        if v not in references:
            references[v] = v
    return references

def process(path, prefix, index):
    references = gather_references(path)
    filter_contentsname(references, path, index)
    for x in list_html_files(path):
        filter_bad_classes(x)
        filter_undesirables(x)
        filter_references(references, index, x)
        filter_fancyvrb(x)
        filter_comments(x)
        filter_unicode(x)
        filter_jinja(prefix, x)
    for x in ('.4ct', '.4tc', '.aux', '.css', '.dvi', '.idv', '.idx', 'j.aux',
              '.lg', '.log', '.tmp', '.xref'):
        p = os.path.join(path, index + x)
        if os.path.exists(p):
            os.unlink(p)
    p = os.path.join(path, '_minted-' + index)
    if os.path.exists(p):
        shutil.rmtree(p)

DOCNAME = sys.argv[1]
VERSION = sys.argv[2] if len(sys.argv) >= 3 else 'latest'

if os.path.exists('html'):
    shutil.rmtree('html')
os.mkdir('html')
args = ['htlatex', os.path.join('..', DOCNAME + '.tex'),
        'xhtml,2,sec-filename,sections+,fn-in,nominitoc,TocLink,bibtex2,index=1,charset=utf8',
        '', '', '-shell-escape']
subprocess.check_call(args, cwd='html')
process('html', VERSION, DOCNAME)
