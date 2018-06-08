
logit = (msg, chapa = "none") ->
  plus = ""
  if chapa != "none"
    color = if chapa == "!" then "red" else if chapa == "+" then "green" else "grey"
    plus = if chapa == "none" then "" else "<a class='ui " + color+ " circular label'>" + chapa + "</a>"
  $("#log").append("<div class='item'><div class='content'>" + plus + " " + msg + "</div></div>")

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

  $('.ui.accordion').accordion()
  b_i.click ->
    v_vags = $("#vagas").val()
    v_insc = $("#chapas").val()
    if 0 < v_vags < 501 and 0 < v_insc < 501
      p_d.before('<div class="ui labeled input"><div class="ui label">Chapa ' + i + '</div><input type="number" min="0" max="10000" id="votesfor" name="votesfor[' + i + ']"></input></div><br>') for i in [1..v_insc]
      $.tab('change tab', 'dat')

  b_d.click ->
    $.tab('change tab', 'res')
    v_vags = $("#vagas").val()
    v_insc = $("#chapas").val()
    vags = v_vags
    a_vots = $("input[id='votesfor']").map( -> return parseInt($(this).val()) ).get()
    results = $("input[id='votesfor']").map( -> return 0).get()
    total = a_vots.reduce (t, s) -> t + s
    logit "Total de chapas inscritas: " + v_insc
    logit "Total de vagas em disputa: " + v_vags
    logit "Total de votos: " + total
    logit "Votos nas chapas: " + a_vots
    quoc = Math.round(total / v_vags)
    logit "Quociente eleitoral de " + quoc
    while vags > 0
      console.log vags + " aqui"
      maxv = Math.max.apply(this,a_vots)
      maxp = a_vots.indexOf(maxv)
      a_vots[maxp] = if maxv > quoc then maxv - quoc else 0
      v_used = [maxp+1]
      results[maxp] = parseInt(results[maxp]) + 1
      while Math.max.apply(this, a_vots) == maxv
        m = a_vots.indexOf(maxv)
        console.log m + " e " + v_used
        v_used.push(m+1)
        results[m] = parseInt(results[m]) + 1
        a_vots[m] = if maxv > quoc then maxv - quoc else 0
      if v_used.length > vags
        p_rs.append("<div class='item'><b class='ui red circular huge label'>!</b>Houve um problema durante a apuração, referente a empate entre chapas disputando número insuficiente de vagas. Tratar isoladamente este caso. Clique em detalhes.</div>")
        logit "Houve empate entre as chapas " + v_used + " disputando " + vags + " vagas!", "!"
        return
      else
        if v_used.length > 1
          logit "Chapas " + v_used + " empataram, cada um tem um representante.", "+"
        else
          logit "Chapa " + v_used[0] + " ficou com a próxima vaga.", v_used[0]
        vags = vags - v_used.length
        logit "Votos restantes: " + a_vots
    for v, k in results
      p_rs.append("<div class='item'>Chapa <b class='ui grey circular label'>" + (k+1) + "</b><div class='right floated content'><div class='ui statistic'><div class='value'>" + v + "</div><div class='label'>Delegado(s)</div></div></div></div>")
    logit "Apuração concluída."
    console.log results

$(document).ready(ready)
$(document).on('page:load', ready)
