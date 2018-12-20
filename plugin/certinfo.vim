" certinfo.vim - Show informations about tls certificates/keys
" Maintainer:   ff0x <ff0x@infr.cat>
" Version:      0.0.1

" TODO:
" - Currently a separator line is required for selecting the information
"   block. In a future version it would be better to split them.

if !executable('openssl')
  echoerr 'openssl binary not found!'
  finish
endif

if has("win64") || has("win32") || has("win16")
  echoerr 'Windows is not supported!'
  finish
endif

if exists("g:loaded_certinfo")
  finish
endif
let g:loaded_certinfo = 1

" Get infos from TLS CSRs, CERTs and CRLs using openssl.
" Supply 'verbose' as argument to get more informations.
function! s:get_cert_info(...) range
  let s:verbose = ''
  if exists('a:1') && a:1 == 'verbose'
    let s:verbose = '-text'
  endif

  let s:firstline = getline("'<")
  if s:firstline =~ '-----BEGIN CERTIFICATE REQUEST-----'
    echohl WarningMsg | echo 'Certificate signing request:' | echohl None
    echo system('echo ' . shellescape(join(getline(a:firstline, a:lastline), "\n")) . '| openssl req -noout -subject ' . s:verbose)
    echohl WarningMsg | echo 'END' | echohl None
  endif
  if s:firstline =~ '-----BEGIN CERTIFICATE-----'
    echohl WarningMsg | echo 'Certificate (PEM):' | echohl None
    echo system('echo ' . shellescape(join(getline(a:firstline, a:lastline), "\n")) . '| openssl x509 -noout -subject -issuer -startdate -enddate -purpose ' . s:verbose)
    echohl WarningMsg | echo 'END' | echohl None
  endif
  if s:firstline =~ '-----BEGIN PKCS7-----'
    echohl WarningMsg | echo 'PKCS#7 Certificate (PEM):' | echohl None
    echo system('echo ' . shellescape(join(getline(a:firstline, a:lastline), "\n")) . '| openssl pkcs7 -noout -print_certs ' . s:verbose)
    echohl WarningMsg | echo 'END' | echohl None
  endif
  if !empty(matchlist(s:firstline, '\(-----BEGIN PRIVATE KEY-----\|-----BEGIN PUBLIC KEY-----\|-----BEGIN RSA PUBLIC KEY-----\)'))
    echohl WarningMsg | echo 'RSA Key (PEM):' | echohl None
    echo system('echo ' . shellescape(join(getline(a:firstline, a:lastline), "\n")) . '| openssl rsa -noout -modulus -check ' . s:verbose)
    echohl WarningMsg | echo 'END' | echohl None
  endif
  if s:firstline =~ '-----BEGIN X509 CRL-----'
    echohl WarningMsg | echo 'Certificate revocation list:' | echohl None
    echo system('echo ' . shellescape(join(getline(a:firstline, a:lastline), "\n")) . '| openssl crl -noout -issuer -lastupdate -nextupdate -crlnumber ' . s:verbose)
    echohl WarningMsg | echo 'END' | echohl None
  endif
endfunction

noremap <silent> <M-c> vip :call <SID>get_cert_info()<CR>

" vim:set et sw=2:
