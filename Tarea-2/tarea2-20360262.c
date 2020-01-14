/** 
 * Autor: Dan Santos
 * Proposito: Este programa leera por pantalla una cadena a buscar (de un maximo de 100 caracteres), 
 *			  y buscara en el arbol de directorios, todos los archivos de texto, las coincidencias
 *			  con el texto ingresado, para cada una se mostrara la linea en donde se encontro.
 */

#define _XOPEN_SOURCE 500

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <ftw.h>

#define MAX_CARACT 100

/** --------- Variables globales --------- */
static pthread_mutex_t printf_mutex;		//Semaforo que controlara el acceso a stdout

char text_searched[MAX_CARACT + 1];			//Guardara el texto a buscar
int quantity = 0;							//Guarda la cantidad de elementos que tiene el arreglo de rutas de archivos
int capacity = 10;							//Guarda la capacidad del arreglo de rutas de arhivos
char **paths;								//Guarda las rutas de todos los archivos encontrados

/** ------- Prototipos de funciones ------ */
void coordinator(void);
void *searchText(void *path_vptr);
static int savePaths(const char *fpath, const struct stat *sb, int tflag, struct FTW *ftwbuf);

/** ------ Programa Principal ----- */
int main(int argc, char *argv[])
{
	//Se asigna memoria para el vector inicial de rutas
	paths = (char **) malloc(sizeof(char *) * capacity);

	//Se llama a la funcion coordinadora
	coordinator();

	//Se libera la memoria del arreglo de rutas
	for(int i = 0; i < quantity; i++)
	{
		free(paths[i]);
	}
	free(paths);

	return 0;
}

/** 
 * Procedimiento que crea recorre el arbol de directorios y crea un arreglo de tantos hilos como archivos se hayan 
 * encontrado, luego se ejecuta cada hilo con la funcion de busqueda, y por ultimo se llama a pthread_join, para
 * esperar a que cada hilo termine su ejecucion.
 */
void coordinator(void)
{
	printf("Ingrese el texto a buscar: ");
	scanf("%100[^\n]s", text_searched);

	int flags = 0;

	if(nftw(".", savePaths, 20, flags) == -1)
		exit(EXIT_FAILURE);

	pthread_t threads[quantity];					//Guardara cada hilo correspondiente a cada ruta de los archivos

	for(int i = 0; i < quantity; i++)
	{
		pthread_create(&threads[i], NULL, searchText, (void *) paths[i]);
	}

	for(int i = 0; i < quantity; i++)
	{
		pthread_join(threads[i], NULL);
	}
}

/** 
 * Funcion que intenta abrir el archivo especificado en la ruta ingresada, si lo logra lee cada linea del archivo
 * y busca las coincidencias del texto buscado, si lo encuentra, imprime la linea en donde se encontro, y por ultimo 
 * cierra el archivo.
 */
void *searchText(void *path_vptr)
{
	FILE *file;
	file = fopen((char *) path_vptr, "r");

	if(file != NULL)
	{
		char line[MAX_CARACT * 27];

		while(fgets(line, MAX_CARACT * 27, file) != NULL)
		{
			if(strstr(line, text_searched) != NULL)
			{
				pthread_mutex_lock(&printf_mutex);
				printf("%s\n", line);
				pthread_mutex_unlock(&printf_mutex);
			}
		}

		fclose(file);
	}

	pthread_exit(NULL);
}

/** 
 * Funcion que sera llamada por nftw, para cada archivo encontrado valida que no se haya sobrepasado la capacidad
 * del arreglo de rutas, si es asi, se redimensiona, sino se asigna memoria para contener la cantidad de caracteres justa
 * para la ruta del archivo actual y por ultimo se copia dicha ruta.
 */
static int savePaths(const char *fpath, const struct stat *sb, int tflag, struct FTW *ftwbuf)
{
	if(FTW_F == tflag)
	{
		if(quantity >= capacity)
		{
			capacity += 30;
			paths = (char **) realloc(paths, sizeof(char *) * capacity);
		}

		paths[quantity] = (char *) malloc(sizeof(char) * (strlen(fpath) + 1));
		strcpy(paths[quantity++], fpath);
	}

	return 0;
}