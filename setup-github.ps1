# =============================================================================
#  Mise en forme du compte GitHub Alexandreschoukroun
#
#  A lancer APRES `gh auth login`. Le script ne supprime rien : les depots a
#  retirer sont listes en commentaire en fin de fichier, a decommenter
#  volontairement.
#
#  Usage :  powershell -ExecutionPolicy Bypass -File .\setup-github.ps1
# =============================================================================

$ErrorActionPreference = 'Stop'

$gh = (Get-Command gh -ErrorAction SilentlyContinue).Source
if (-not $gh) { $gh = "$env:ProgramFiles\GitHub CLI\gh.exe" }
if (-not (Test-Path $gh)) { throw "gh introuvable. Installez GitHub CLI puis relancez." }

& $gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw "gh n'est pas authentifie. Lancez d'abord : gh auth login" }

$user = (& $gh api user --jq .login)
Write-Host "Compte : $user" -ForegroundColor Cyan

# --- 1. Depot de profil ------------------------------------------------------
# Le depot <pseudo>/<pseudo> affiche son README en haut de la page de profil.
Write-Host "`n[1/3] Depot de profil" -ForegroundColor Cyan
& $gh repo view "$user/$user" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "  creation de $user/$user"
  & $gh repo create "$user/$user" --public --description "Profil" --disable-issues --disable-wiki
} else {
  Write-Host "  deja existant"
}

if (-not (Test-Path .git)) {
  git init -b main
  git remote add origin "https://github.com/$user/$user.git"
}
git add README.md
git commit -m "Profil : presentation, stack et produits" 2>&1 | Out-Null
git push -u origin main

# --- 2. Descriptions et sujets ----------------------------------------------
# Redigees a partir du contenu reel de chaque depot.
Write-Host "`n[2/3] Descriptions et sujets" -ForegroundColor Cyan

$repos = @(
  @{ n = 'mspr-serveurless-cofrap'
     d = "Authentification serverless : generation de mots de passe, 2FA TOTP et expiration de compte. Python 3.11 sur OpenFaaS."
     t = 'python,openfaas,serverless,authentication,totp' },

  @{ n = 'ImageConverter'
     d = "ScreenCraft : transforme des captures brutes en visuels promotionnels. React 19 et TypeScript."
     t = 'react,typescript,image-processing,design-tools' },

  @{ n = 'Formation-Archi'
     d = "API web de gestion hoteliere en C# : reservations, clients, personnel et services."
     t = 'csharp,dotnet,rest-api,architecture' },

  @{ n = 'FitupBack'
     d = "Back-end Fitup : API Node.js reliant l'application mobile a sa base de donnees."
     t = 'nodejs,api,backend' },

  @{ n = 'FitupFront'
     d = "Front-end Fitup : mise en relation des adherents avec des coachs en nutrition."
     t = 'frontend,javascript' },

  @{ n = 'rest_mediatekdocument'
     d = "API REST sur la base MySQL Mediatek86, pour la gestion documentaire d'une mediatheque."
     t = 'php,rest-api,mysql' },

  @{ n = 'site-pour-upload'
     d = "Outil web de correction et d'affichage de fichiers CSV clients."
     t = 'php,csv' }
)

foreach ($r in $repos) {
  Write-Host "  $($r.n)"
  & $gh repo edit "$user/$($r.n)" --description $r.d
  & $gh repo edit "$user/$($r.n)" --add-topic $r.t
}

# --- 3. Bio du profil --------------------------------------------------------
# Necessite le droit `user` :  gh auth refresh -s user
Write-Host "`n[3/3] Bio du profil" -ForegroundColor Cyan
$bio = "Developpeur C++ embarque et temps reel. Vision, acoustique et radar, du capteur a la decision."
& $gh api -X PATCH /user -f bio="$bio" -f location="Herault, France" -f blog="https://adscope.cloud" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "  refuse : il manque le droit 'user'. Lancez  gh auth refresh -s user  puis relancez ce script." -ForegroundColor Yellow
} else {
  Write-Host "  bio, localisation et lien mis a jour"
}

Write-Host "`nTermine." -ForegroundColor Green


# =============================================================================
#  A DECIDER VOUS-MEME : depots vides ou sans contenu utile.
#
#  Ils occupent la page de profil sans rien demontrer. Les passer en prive est
#  reversible, la suppression ne l'est pas. Rien n'est execute automatiquement.
#
#  Passer en prive (reversible) :
#
#    & $gh repo edit "$user/Test"        --visibility private --accept-visibility-change-consequences
#    & $gh repo edit "$user/NewRepo"     --visibility private --accept-visibility-change-consequences
#    & $gh repo edit "$user/testRida"    --visibility private --accept-visibility-change-consequences
#    & $gh repo edit "$user/Forum"       --visibility private --accept-visibility-change-consequences
#    & $gh repo edit "$user/uiui.github.io" --visibility private --accept-visibility-change-consequences
#    & $gh repo edit "$user/Formes-927f85e571703340aba50e5ba47ad8dc05c10b17" --visibility private --accept-visibility-change-consequences
#
#  Depots dont j'ignore le contenu, a decrire par vous :
#    planifood                      (Next.js, README encore celui de create-next-app)
#    C1--schoukroun-tene-broccoli   (JavaScript, aucun README)
#    PasswordManager                (Python, aucun README)
#    MediatekDoc / Mediatek86 / mesvoyages  (projets BTS SIO, aucun README)
#    alexandre-portfolio            (ancien portfolio, 14,7 Mo)
# =============================================================================
