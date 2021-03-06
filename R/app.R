#' App
#' 
#' Run app
#' @param credentials a named list of credentials
#' @import shiny
#' @import shinyMobile
#' @import yaml
#' @import RMySQL
#' @import DBI
#' @export
app <- function(credentials){

  # Connect to database
  con <- DBI::dbConnect(drv = RMySQL::MySQL(),
                        dbname = credentials$dbname,
                        host = credentials$host,
                        user = credentials$user,
                        pass = credentials$pass,
                        port = credentials$port)
  
  
  # Define function for registering workers
  register <- function(nombre,
                       apellido,
                       tel,
                       email, 
                       lugar){
    df <- tibble(nombre,
                 apellido,
                 tel,
                 email, 
                 lugar,
                 time_stamp = Sys.time())
    # Get new number
    old <- dbGetQuery(conn = con,
                      "select MAX(id) FROM users;")
    new <- as.numeric(old) +1
    df$id <- new
    
    try_add <- 
      dbWriteTable(conn = con,
                   name = 'users',
                   value = df,
                   append = TRUE)
    if(try_add){
      return(new)
    }
  }
  
  # Define function for reporting case
  report <- function(case_id,
                     case_name,
                     case_date_symptoms,
                     case_date_dx){
    
    df <- tibble(case_id,
                 case_name,
                 case_date_symptoms,
                 case_date_dx,
                 time_stamp = Sys.time())
    out <- dbWriteTable(conn = con,
                        name = 'cases',
                        value = df,
                        append = TRUE)
    return(out)
  }
  
  ui = f7Page(
    
    init = f7Init(
      skin = 'auto', #  c("ios", "md", "auto", "aurora"),
      theme = 'light', #c("dark", "light"),
      filled = TRUE
    ),
    title = "BCV: Inscripción | Registration",
    
    
    f7TabLayout(
      navbar = f7Navbar(
        title = "Tabs",
        hairline = FALSE,
        shadow = TRUE,
        left_panel = FALSE,
        right_panel = FALSE
      ),
      f7Tabs(
        animated = TRUE,
        f7Tab(
          tabName = "REGISTRATION | INSCRIPCIÓN",
          icon = f7Icon("email"),
          active = TRUE,
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              
              shinyMobile::f7Text('nombre', 'Nombre | First name'),
              shinyMobile::f7Text('apellido', 'Apellido | Last name'),
              shinyMobile::f7Text('tel', 'Teléfono | Phone'),
              shinyMobile::f7Text('email', 'E-mail'),
              shinyMobile::f7Text('lugar', 'Lugar de trabajo | Work place'),
              br(),
              column(12,
                     align = 'center',
                     f7Button('register', 'HAZ CLICK AQUÍ PARA DAR DE ALTA Y RECIBIR UN NÚMERO ID', rounded = TRUE),
                     h1(textOutput('number_text')),
                     h2(textOutput('done_text')),
                     f7Link(label = "INSTRUCCIONES PARA INSTALAR/CONFIGURAR LA APLICACIÓN EN EL MÓVIL", src = "https://github.com/databrew/bcv/blob/master/docs/phone_documentation_es.md", external = TRUE),
                     br(),
                     f7Link(label = "(Instructions for installing/configuring the app on your phone)", src = "https://github.com/databrew/bcv/blob/master/docs/phone_documentation.md", external = TRUE)
              ),
              
              title = "Registration | Inscripción",
              # footer = tagList(
              #   f7Button(color = "blue", label = "Databrew LLC", src = "https://www.databrew.cc"),
              #   f7Button(color = 'blue', label = 'BCV', src = 'https://github.com/databrew/bcv')
              # )
            )
          )
        ),
        f7Tab(
          tabName = "REPORT CASE | INFORMAR CASO",
          icon = f7Icon("cloud_upload"),
          active = FALSE,
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Report case | Informar de un caso",
              uiOutput('report_ui'),
              
              footer = tagList(
                f7Button(color = "blue", label = "Databrew LLC", src = "https://www.databrew.cc"),
                f7Button(color = 'blue', label = 'BCV', src = 'https://github.com/databrew/bcv')
              )
            )
          )
        )
      )
    )
    
  )
  
  server <- function(input, output, session) {
    
    done <- reactiveVal(value = FALSE)
    the_text <- reactiveVal(value = '')
    the_number <- reactiveVal(value = NA)
    observeEvent(input$register, {
      
      # Check status
      ok <- FALSE
      nombre <- input$nombre
      apellido <- input$apellido
      tel <- input$tel
      email <- input$email
      lugar <- input$lugar
      is_empty <- function(x){nchar(x) < 2}
      if(!is_empty(nombre)){
        if(!is_empty(apellido)){
          if(!is_empty(tel)){
            if(!is_empty(email)){
              if(!is_empty(lugar)){
                ok <- TRUE
              }
            }
          }
        }
      }
      
      if(ok){
        done(TRUE)
      }
      
      # Update done text
      is_done <- done()
      if(is_done){
        the_text('Ahora haz clic abajo para instrucciones para descargar la aplicación en tu móvil')
      } else {
        the_text('Hay que llenar primero todos los campos para poder registrar.')
      }
      
      # Assign number
      if(is_done){
        x <- register(nombre,
                      apellido,
                      tel,
                      email, 
                      lugar)
        the_number(x)
      }
      
      
    })
    
    output$done_text <- renderText({
      out <- the_text()
      return(out)
      
    })
    
    output$number_text <- renderText({
      tn <- the_number()
      if(is.na(tn)){
        return(NULL)
      } else {
        return(paste0('Tu número de identificación es: ',
                      tn))
      }
    })
    
    logged_in <- reactiveVal(value = FALSE)
    observeEvent(input$log_in,{
      user <- input$user
      pass <- input$pass
      ok <- FALSE
      if(user == 'admin' &
         pass == 'admin'){
        ok <- TRUE
      }
      if(ok){
        logged_in(TRUE)
      }
    })
    
    output$report_ui <- renderUI({
      
      li <- logged_in()
      if(li){
        fluidPage(
          f7Text('case_id', 'BCV ID of case'),
          f7Text('case_name', 'Name of case'),
          dateInput('case_date_symptoms', 'Date of symptoms onset'),
          dateInput('case_date_dx', 'Date of diagnosis'),
          actionButton('submit_case', 'Report case | Informar del caso'),
          textOutput('submit_case_text')
        )
      } else {
        fluidPage(
          f7Text('user', 'Username'),
          f7Text('pass', 'Password'),
          f7Button('log_in', 'Log in', 
                   rounded = TRUE),
          br(),
          p('Para poder informar de un caso, hay que ser "administrador" con nombre de usuario y contraseña. Si necesitas informar de un caso y no tienes nombre de usuario/contraseña: help@databrew.cc'),
          p('In order to be able to report a case, you must have an administrator username / password. If you need one, email help@databrew.cc')
        )
      }
    })
    
    submitted_text <- reactiveVal(value = '')
    observeEvent(input$submit_case, {
      case_id <- input$case_id
      case_name <- input$case_name
      case_date_symptoms <- input$case_date_symptoms
      case_date_dx <- input$case_date_dx
      x <- report(case_id = case_id,
                  case_name = case_name,
                  case_date_symptoms = case_date_symptoms,
                  case_date_dx = case_date_dx)
      if(x){
        submitted_text('Información enviada con éxito.\nCase info successfully submitted.')  
      } else {
        submitted_text('Problem. Problema. Contact: joe@databrew.cc')
      }
      
    })
    
    output$submit_case_text <- renderText({
      out <- submitted_text()
      out
    })
    
  }
  
  onStop(function() {
    dbDisconnect(con)
  })
  
  shinyApp(ui = ui, server = server)
}

# Example:
# app(credentials = yaml::yaml.load_file('../credentials/credentials.yaml'))
