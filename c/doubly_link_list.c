#include <stdio.h>
#include <stdlib.h>

//
// gcc -o doubly_link_list.o doubly_link_list.c
//

struct Node
{
  int num;
  struct Node *p_pre;
  struct Node *p_next;
};

int count;

struct Node* create ()
{
  struct Node *p_head = NULL;
  struct Node *p_tail, *p_new;
  count = 0;
  p_new = (struct Node*) malloc (sizeof (struct Node));
  printf ("Please enter a number\n");
  scanf ("%d", &p_new->num);
  while (p_new->num != 0) {
    count ++;
    if (count == 1) {
      p_new->p_next = NULL;
      p_new->p_pre = NULL;
      p_tail = p_new;
      p_head = p_new;
    } else {
      p_new->p_next = NULL;
      p_new->p_pre = p_tail;
      p_tail->p_next = p_new;
      p_tail = p_new;
    }
    p_new = (struct Node*) malloc (sizeof (struct Node));
    printf ("Please enter a number\n");
    scanf ("%d", &p_new->num);
  }
  free (p_new);
  return p_head;
}

struct Node* bulk_create (int total_length)
{
  struct Node *p_head = NULL;
  struct Node *p_tail, *p_new;
  int i;
  count = 0;
  for (i = 0; i < total_length; i++) {
    p_new = (struct Node*) malloc (sizeof (struct Node));
    p_new->num = i + 1;
    count ++;
    if (count == 1) {
      p_new->p_next = NULL;
      p_new->p_pre = NULL;
      p_tail = p_new;
      p_head = p_new;
    } else {
      p_new->p_next = NULL;
      p_new->p_pre = p_tail;
      p_tail->p_next = p_new;
      p_tail = p_new;
    }
  }
  return p_head;
}

struct Node* get_tail (struct Node *p_head)
{
  struct Node *p_tail;
  p_tail = p_head;
  while (p_tail->p_next != NULL) {
    p_tail = p_tail->p_next;
  }
  return p_tail;
}

struct Node* head_insert_node (struct Node *p_head)
{
  struct Node *p_new;
  printf ("---Insert member at first---\n");
  p_new = (struct Node*) malloc (sizeof (struct Node));
  scanf ("%d", &p_new->num);
  p_new->p_pre = NULL;
  p_new->p_next = p_head;
  p_head->p_pre = p_new;
  p_head = p_new;
  count ++;
  return p_head;
}

struct Node* tail_insert_node (struct Node *p_tail)
{
  struct Node *p_new;
  printf ("---Insert a member at last---\n");
  p_new = (struct Node*) malloc (sizeof (struct Node));
  scanf ("%d", &p_new->num);
  p_new->p_pre = p_tail;
  p_new->p_next = NULL;
  p_tail->p_next = p_new;
  p_tail = p_new;
  return p_tail;
}

void delete_node (struct Node *p_head, int index)
{
  int i;
  struct Node *p_temp;
  struct Node *p_pre;
  p_temp = p_head;
  p_pre = p_temp;
  printf ("---Delete NO.%d memeber---\n", index);
  for (i = 1; i < index; i++) {
    p_pre = p_temp;
    p_temp = p_temp->p_next;
  }
  p_pre->p_next = p_temp->p_next;
  free (p_temp);
  count --;
}

void asc_show (struct Node *p_head)
{
  struct Node *p_temp;
  printf ("---The list contains %d members:---\n", count);
  if (count > 0) {
    p_temp = p_head;
    while (p_temp != NULL) {
      printf ("number is %d\n", p_temp->num);
      p_temp = p_temp->p_next;
    }
  }
}

void desc_show (struct Node *p_tail)
{
  struct Node *p_temp;
  printf ("---The list contains %d members:---\n", count);
  if (count > 0) {
    p_temp = p_tail;
    while (p_temp != NULL) {
      printf ("number is %d\n", p_temp->num);
      p_temp = p_temp->p_pre;
    }
  }
}

void free_link_list (struct Node *p_head)
{
  if (count == 0 || p_head == NULL) {
    return;
  }
  struct Node *p_temp;
  while (p_head != NULL) {
    if (p_head->p_next != NULL) {
      p_temp = p_head;
      p_head = p_head->p_next;
    } else {
      p_temp = p_head;
      p_head = NULL;
    }
    free (p_temp);
    count --;
  }
}

int main (int argc, char const *argv[])
{
  struct Node *p_head, *p_tail;
  while (1) {
    printf ("1. create doubly link list\n");
    printf ("2. head insert doubly link list\n");
    printf ("3. tail insert doubly link list\n");
    printf ("4. delete doubly link list\n");
    printf ("5. bulk create doubly link list\n");
    printf ("6. asc show doubly link list\n");
    printf ("7. desc show doubly link list\n");
    printf ("8. exit\n");
    printf ("Please input your option\n");
    int option;
    int exit_flag = 0;
    scanf ("%d", &option);
    switch (option) {
      case 1:
        free_link_list (p_head);
        p_head = create ();
        break;
      case 2:
        p_head = head_insert_node (p_head);
        break;
      case 3:
        p_tail = get_tail (p_head);
        p_tail = tail_insert_node (p_tail);
        break;
      case 4:
        printf ("Please input the index\n");
        int index;
        scanf ("%d", &index);
        if (index > count) {
          printf ("index is too large\n");
        } else {
          delete_node (p_head, index);
        }
        break;
      case 5:
        free_link_list (p_head);
        printf ("Please input total length\n");
        int total_length;
        scanf ("%d", &total_length);
        p_head = bulk_create (total_length);
        break;
      case 6:
        asc_show (p_head);
        break;
      case 7:
        p_tail = get_tail (p_head);
        desc_show (p_tail);
        break;
      case 8:
        free_link_list (p_head);
        exit_flag = 1;
        break;
      default:
        printf ("Unknown option\n");
    }
    if (exit_flag) {
      break;
    }
  }
  return 0;
}
