#include <stdio.h>
#include <stdlib.h>

//
// gcc -o link_list.o link_list.c
//

struct Node
{
  int num;
  struct Node *p_next;
};

int count;

struct Node* create ()
{
  struct Node *p_head = NULL;
  struct Node *p_end, *p_new;
  count = 0;
  p_end = p_new = (struct Node*) malloc (sizeof (struct Node));
  printf ("Please enter a number\n");
  scanf ("%d", &p_new->num);
  while (p_new->num != 0) {
    count ++;
    if (count == 1) {
      p_new->p_next = p_head;
      p_end = p_new;
      p_head = p_new;
    } else {
      p_new->p_next = NULL;
      p_end->p_next = p_new;
      p_end = p_new;
    }
    p_new = (struct Node*) malloc (sizeof (struct Node));
    printf ("Please enter a number\n");
    scanf ("%d", &p_new->num);
  }
  free (p_new);
  return p_head;
}

void print (struct Node *p_head)
{
  struct Node *p_temp;
  printf ("---The list contains %d members:---\n", count);
  p_temp = p_head;
  while (p_temp != NULL) {
    printf ("number is %d\n", p_temp->num);
    p_temp = p_temp->p_next;
  }
}

struct Node* insert_node (struct Node *p_head)
{
  struct Node *p_new;
  printf ("---Insert member at first\n");
  p_new = (struct Node*) malloc (sizeof (struct Node));
  scanf ("%d", &p_new->num);
  p_new->p_next = p_head;
  p_head = p_new;
  count ++;
  return p_head;
}

void delete_node (struct Node *p_head, int index)
{
  int i;
  struct Node *p_temp;
  struct Node *p_pre;
  p_temp = p_head;
  p_pre = p_temp;
  printf ("---Delete NO%d memeber---\n", index);
  for (i = 1; i < index; i++) {
    p_pre = p_temp;
    p_temp = p_temp->p_next;
  }
  p_pre->p_next = p_temp->p_next;
  free (p_temp);
  count --;
}

int main (int argc, char const *argv[])
{
  struct Node *p_head;
  while (1) {
    printf ("1. create link list\n");
    printf ("2. insert link list\n");
    printf ("3. delete link list\n");
    printf ("4. exit\n");
    printf ("Please input your option\n");
    int option;
    int exit_flag = 0;
    scanf ("%d", &option);
    switch (option) {
      case 1:
        p_head = create ();
        break;
      case 2:
        p_head = insert_node (p_head);
        break;
      case 3:
        printf("Please input the index\n");
        int index;
        scanf ("%d", &index);
        if (index > count) {
          printf ("index is too large\n");
        } else {
          delete_node (p_head, index);
        }
        break;
      case 4:
        exit_flag = 1;
        break;
      default:
        printf ("Unknown option\n");
    }
    if (exit_flag) {
      break;
    }
    printf ("Show current link list\n");
    print (p_head);
  }
  return 0;
}
