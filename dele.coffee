
lcount = 1 # Contador de linhas/passos da apuração

logit = (msg, chapa = "none") ->
  plus = ""
  pre = ""
  if chapa != "none"
    if typeof chapa == "object"
      plus = ("<a class='ui grey circular label'>" + c + "</a>" for c in chapa)
      plus.toString(' ')
      plus = "<a class='ui green label'>+</a>Chapas " + plus
    else
      color = if chapa == "!" then "red" else if chapa == "+" then "green" else "grey"
      plus = switch
        when chapa == "none" then ""
        when chapa == "!" then "<a class='ui " + color+ " label'>" + chapa + "</a>"
        else  "<a class='ui " + color+ " circular label'>" + chapa + "</a>"
    pre = lcount + ": "
    lcount += 1
  $("#log").append("<div class='item'><div class='content'>" + pre + plus + " " + msg + "</div></div>")

ready = ->
  p_i = $("#initial")
  p_d = $("#data")
  p_r = $("#result")
  p_rs = $("#simple")
  p_rd = $("#log")
  v_insc = $("#chapas").val()
  v_vags = $("#vagas").val()
  b_i = $("#initial-finish")
  b_d = $("#data-finish")
  b_a = $("#about-box")

  $('.ui.accordion').accordion()

  b_a.click ->
    $('.ui.modal').modal('show')

  b_i.click ->
    v_vags = $("#vagas").val()
    v_insc = $("#chapas").val()
    if 0 < v_vags < 501 and 0 < v_insc < 501
      p_d.before('<div class="ui labeled input"><div class="ui blue label">Chapa ' + i + '</div><input type="number" min="0" max="10000" id="votesfor" name="votesfor[' + i + ']"></input></div><br>') for i in [1..v_insc]
      $.tab('change tab', 'dat')

  b_d.click ->
    $.tab('change tab', 'res')
    v_vags = parseInt($("#vagas").val())
    v_insc = parseInt($("#chapas").val())
    v_inva = 0 #Inscrições de chapa inválidas
    a_vots = $("input[id='votesfor']").map( -> return parseInt($(this).val() or 0) ).get()
    results = $("input[id='votesfor']").map( -> return 0).get()
    total = a_vots.reduce (t, s) -> t + s
    brn = parseInt($("#vbrancos").val() or 0)
    nls = parseInt($("#vnulos").val() or 0)
    logit "Total de chapas inscritas: " + v_insc
    logit "Total de vagas em disputa: " + v_vags
    logit "Votos em branco: " + brn
    logit "Votos nulos: " + nls
    logit "Votos nas chapas: " + a_vots
    logit "Total de votos: " + (total + brn + nls)

    v_min = switch
      when v_insc - v_inva == 2 then Math.ceil(total * 0.1)
      when v_insc - v_inva > 2 then Math.ceil(total * 0.05)
      else 1
    logit "Mínimo de votos necessários para concorrer: " + v_min
    p = 0
    for chapa_votes in a_vots
      if chapa_votes < v_min
        logit "Chapa " + (p+1) + " não obteve o mínimo de votos necessários e foi eliminada."
        v_inva += 1
        results[p] = 'X'
        a_vots[p] = 0
        total = a_vots.reduce (t, s) -> t + s
      p += 1

    logit "Total de chapas aptas: " + (v_insc - v_inva)
    r_vags = Math.round(total/10)
    if v_vags > r_vags
      vags = r_vags
      logit "Total de vagas reajustado para " + r_vags + " devido à quantidade de votantes"
    else
      vags = v_vags
    logit "Total de votos válidos: " + total
    logit "Votos nas chapas: " + a_vots
    quoc = (total / vags).toFixed(1)
    logit "Quociente eleitoral de " + quoc
    logit "Iniciando a apuração"
    while vags > 0
      maxv = Math.max.apply(this,a_vots)
      maxp = a_vots.indexOf(maxv)
      a_vots[maxp] = if maxv > quoc then Number(Math.round((maxv - quoc) + 'e2') + 'e-2') else 0
      v_used = [maxp+1]
      results[maxp] = parseInt(results[maxp]) + 1
      while Math.max.apply(this, a_vots) == maxv
        m = a_vots.indexOf(maxv)
        v_used.push(m+1)
        results[m] = parseInt(results[m]) + 1
        a_vots[m] = if maxv > quoc then maxv - quoc else 0
      if v_used.length > vags
        p_rs.append("<div class='item'><b class='ui red circular huge label'>!</b>Houve um problema durante a apuração, referente a empate entre chapas disputando número insuficiente de vagas. Tratar isoladamente este caso. Clique em detalhes.</div>")
        logit "Houve empate entre as chapas " + v_used + " disputando " + vags + " vagas!", "!"
        return
      else
        if v_used.length > 1
          logit "empataram, cada um tem um representante.", v_used
        else
          logit "Chapa " + v_used[0] + " garantiu uma vaga.", v_used[0]
        vags = vags - v_used.length
        logit "Votos restantes: " + a_vots
    for v, k in results
      color = switch
        when v == 0 then "grey"
        when v == 'X' then "yellow"
        else "blue"
      v = 0 if v == 'X'
      label = if v > 1 then "Delegados" else "Delegado"
      p_rs.append("<div class='item'>Chapa <b class='ui circular label'>" + (k+1) + "</b><div class='right floated content'><div class='ui " + color + " statistic'><div class='value'>" + v + "</div><div class='label'>" + label + "</div></div></div></div>")
    logit "Apuração concluída."

$(document).ready(ready)
$(document).on('page:load', ready)
